import numpy as np
import matplotlib.pyplot as plt

#see wiki for rd update equations

#discrete laplacian

def laplacian(A):
    laplacian = (
            -4*A
            + np.roll(A, (0, -1), (0, 1)) 
            + np.roll(A, (0, 1), (0, 1))
            + np.roll(A, (-1, 0), (0, 1)) 
            + np.roll(A, (1, 0), (0, 1))
    )
    return laplacian

def update(A, B, D_A, D_B, f, k, delta_t):
    # """updates A and B based on the gram_scott model

    # Args:
    #     A (np.array): Chemical A
    #     B (np.array): Chemical B
    #     D_A (float): diffusion coefficient for A
    #     D_B (float): diffusion coefficient for B
    #     f (float): feed rate
    #     k (float): kill rate
    #     delta_t (float): time step

    # Returns:
    #     tuple: return tuple of (A, B) updated
    # """
    #calculate laplacians
    laplace_A = laplacian(A)
    laplace_B = laplacian(B)

    #update based on wiki formula
    diff_A = (D_A*laplace_A - A*B**2 + f*(1-A)) * delta_t
    diff_B = (D_B*laplace_B + A*B**2 - (k+f)*B) * delta_t

    #update A & B
    A += diff_A
    B += diff_B
    
    return A, B

def initial_condition(n, conc=0.5):
    #initialize concentration of A & B based on weight
    A = (1 - conc) * np.ones((n, n)) + conc*np.random.random((n, n))
    B = conc * np.random.random((n, n))

    #central sqr
    n2 = n//2
    r = int(n/10)

    A[n2-r:n2+r, n2-r:n2+r] = 0.5 #good for visuals
    B[n2-r:n2+r, n2-r:n2+r] = 0.25 
    
    return A, B

def draw(A, B):
    _, ax, = plt.subplots(1, 2)
    ax[0].imshow(A, cmap='viridis')
    ax[1].imshow(B, cmap='viridis')
    ax[0].set_title('A')
    ax[1].set_title('B')
    ax[0].axis('off')
    ax[1].axis('off')

    plt.show()

# A, B = initial_condition(200)
# draw(A, B)

# A, B = initial_condition(200)

# for t in range(iterations):
#     A, B = update(A, B, D_A, D_B, f, k, delta_t)

# draw(A, B)

import matplotlib.animation as animation
from matplotlib.colors import Normalize #rescale colors

def anim_draw(A, B):
    fig, ax = plt.subplots(1, 2)
    imA = ax[0].imshow(A, animated=True, cmap='viridis')
    imB = ax[1].imshow(B, animated=True, cmap='viridis')
    ax[0].set_title('A')
    ax[1].set_title('B')
    ax[0].axis('off')
    ax[1].axis('off')

    return fig, imA, imB

def anim_update(frame, updates_per_frame, A, B, D_A, D_B, f, k, delta_t):
    # """update function used for animating the simulation.

    # Args:
    #     frame (np.array): takes the kth frame (it breaks without this)
    #     updates_per_frame (int): the amount of iterations per frame
    #     A (np.array): Chemical A
    #     B (np.array): Chemical B
    #     D_A (float): diffusion coefficient of A
    #     D_B (float): diffusion coefficient of B
    #     f (float): feed rate
    #     k (float): kill rate
    #     delta_t (float): time step

    # Returns:
    #     tuple: return tuple (imA, imB) updated and normalized
    # """
    #ideally would not use global var
    global imA, imB

    #update based on desired updates_per_frame count
    for _ in range(updates_per_frame):
        A, B = update(A, B, D_A, D_B, f, k, delta_t)

    imA.set_array(A)
    imB.set_array(B)

    #normalize color
    imA.set_norm(Normalize(vmin=np.amin(A), vmax=np.amax(A)))
    imB.set_norm(Normalize(vmin=np.amin(B), vmax=np.amax(B)))

    return imA, imB



if __name__ == '__main__':
    #time step
    delta_t = 1.0
    #diffusion coeff
    D_A = 0.1
    D_B = 0.08
    #feed/kill rate
    f = 0.06
    k = 0.062
    #grid size
    n = 200
    #num iterations
    iterations = 10_000

    A, B = initial_condition(n)
    fig, imA, imB = anim_draw(A, B)

    updates_per_frame = 25
    anim_args = (updates_per_frame, A, B, D_A, D_B, f, k, delta_t)

    anim = animation.FuncAnimation(fig,
        anim_update,
        fargs=anim_args,
        interval=10,
        frames=int(iterations/updates_per_frame),
        blit=True)
    
    plt.show()


