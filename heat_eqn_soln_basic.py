import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation  
from numba import njit


plate_length = 50
max_iter_time = 1000

alpha = 2
delta_x = 1

#calculated params
delta_t = (delta_x ** 2) / (4* alpha)
gamma = (alpha * delta_t) / (delta_x ** 2)

#initialize soln : grid of u(k, i, j)
u = np.empty((max_iter_time, plate_length, plate_length))

#initial conditions
u_initial = 0.0

#boundary conditions 
u_top = 100.0
u_left = 100.0
u_right = 100.0
u_bottom = 100.0
#set initial condition
u.fill(u_initial)

#set boundaries
u[:, (plate_length - 1):, :] = u_top #fills m row of each k layer
u[:, :, :1] = u_left #fills 0th column of each k layer
u[:, :, (plate_length - 1):] = u_right #fills nth column of k layers
u[:, :1, 1:] = u_bottom #fills 0th row (excluding 0th and nth column)

@njit(fastmath=True)
def calculate(u):
    for k in range(0, max_iter_time-1, 1):
        for i in range(1, plate_length-1, delta_x):
            for j in range(1, plate_length-1, delta_x):
                u[k+1, i, j] = gamma*( \
                u[k][i+1][j] + u[k][i-1][j] + \
                u[k][i][j+1] + u[k][i][j-1] - 4*u[k][i][j]) + \
                u[k][i][j]
    return u         

def kth_heatmap(u_k, k):
    #clear current figure
    plt.clf()

    plt.title(f'Temp @ t {k*delta_t:.3f} unit time')
    plt.xlabel('x')
    plt.ylabel('y')

    #actual plot of u @ time step k
    plt.pcolormesh(u_k, shading='gouraud', cmap=plt.cm.plasma, vmin=0, vmax=100)
    plt.colorbar()

    return plt

def animate(k):
    kth_heatmap(u[k], k)

if __name__ == "__main__":
    u = calculate(u)

    anim = FuncAnimation(plt.figure(), animate, 
        interval=1, frames=max_iter_time, repeat=False)

    plt.show()
#anim.save('heat_eq_soln_basic.gif')