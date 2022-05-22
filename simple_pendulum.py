import numpy as np
from numpy import sin, cos
from scipy.integrate import odeint
from matplotlib import pyplot as plt

#define eq
def equations(y0, t):
    theta, x = y0
    f = [x, -(g/l)*sin(theta)]
    return f

def plot_results(time, theta1, theta2):
    plt.plot(time, theta1[:,0]) #2 columns but only need first
    plt.plot(time, theta2)
    s = f'(Initial Angle = {str(initial_angle)} degrees)'
    plt.title('Pendulum Motion:' + s)
    plt.xlabel('time (s)')
    plt.ylabel('angle (rad)')
    plt.grid(True)
    plt.legend(['nonlinear', 'linear'], loc='lower right')
    plt.show()

#parameters
g = 9.81
l = 1.0 #length
time = np.arange(0, 10, 0.025) #(start, stop, time step)

#initial conditions
initial_angle = 45.0 #degrees
theta0 = np.radians(initial_angle) #convert to radians
x0 = np.radians(0.0) #convert degrees per second to radians


#find soln to non linear
theta1 = odeint(equations, [theta0, x0], time) #ode integrator: solves for theta values in nonlinear case

#find soln to linear
w = np.sqrt(g/l)
theta2 = [theta0*cos(w*t) for t in time] #iterate through time and evaluate theta0*cos(wt)

#plot
plot_results(time, theta1, theta2) #plot nonlinear and linear case