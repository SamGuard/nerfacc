from curses import echo
import torch

print(torch.__version__)
print(torch.cuda.is_available())
print(torch.version.cuda)

try:
  import numpy
  print(torch.zeros(1).cuda())
except:
  print("No numpy installed")