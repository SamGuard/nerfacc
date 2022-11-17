import math
import os
import sys
import json
import numpy as np
import torch
from radiance_fields.mlp import VanillaNeRFRadianceField
from nerfacc import ContractionType, OccupancyGrid

WIDTH, HEIGHT = 800


def loadCams(rootFP: str, subjectId):
    if not rootFP.startswith("/"):
        # allow relative path. e.g., "./data/nerf_synthetic/"
        rootFP = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "..",
            "..",
            rootFP,
        )

    data_dir = os.path.join(rootFP, subjectId)
    with open(os.path.join(data_dir, "transforms_test.json"), "r") as fp:
        meta = json.load(fp)

    camtoworlds = []

    for i in range(len(meta["frames"])):
        frame = meta["frames"][i]
        camtoworlds.append(frame["transform_matrix"])

    camtoworlds = torch.from_numpy(np.stack(camtoworlds, axis=0)).to(torch.float32)

    camera_angle_x = float(meta["camera_angle_x"])
    focal = 0.5 * WIDTH / np.tan(0.5 * camera_angle_x)

    K = torch.tensor(
        [
            [focal, 0, WIDTH / 2.0],
            [0, focal, HEIGHT / 2.0],
            [0, 0, 1],
        ],
        dtype=torch.float32,
    )

    return camtoworlds, K


if __name__ == "__main__":
    DEVICE = "cpu"
    networkFileName = sys.argv[1]
    AABB = [-1.5,-1.5,-1.5,1.5,1.5,1.5]
    RENDER_N_SAMPLES = 1024
    GRID_RESOLUTION = 128

    radianceField = VanillaNeRFRadianceField()
    radianceField.load_state_dict(torch.load(os.path.join(".","network_out", networkFileName), DEVICE))
    radianceField.eval()


    CONTRACTION_TYPE = ContractionType.AABB
    scene_aabb = torch.tensor(AABB, dtype=torch.float32, device=DEVICE)
    near_plane = None
    far_plane = None
    render_step_size = (
        (scene_aabb[3:] - scene_aabb[:3]).max()
        * math.sqrt(3)
        / RENDER_N_SAMPLES
    ).item()


    occupancy_grid = OccupancyGrid(
        roi_aabb=AABB,
        resolution=GRID_RESOLUTION,
        contraction_type=CONTRACTION_TYPE,
    ).to(DEVICE)

    localCam, localK, = loadCams("../data/nerf_synthetic/", "lego")
    camToWorld = localCam.to(DEVICE)
    K = localK.to(DEVICE)

    for c, k in zip(camToWorld, K):
        pass