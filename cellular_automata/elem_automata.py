from matplotlib.animation import FuncAnimation
import numpy as np
import matplotlib.pyplot as plt

# @jitclass([
#     ('rule', types.int64),
#     ('transition_rule', types.DictType(types.UniTuple(types.int64, 3), types.int64)),
#     ('dim', types.int64),
#     ('mat', types.Array(types.float64, 2, 'C')),
#     ('evomat', types.Array(types.float64, 2, 'C'))
# ])


class Elementary:
    #explicitly states instance attributes for memory space saving and faster attribute access
    #use '__dict__' for dynamic assignment and adding attributes
    __slots__ = \
        (
        'rule', 
        'transition_rule',
        'dim',
        'mat',
        'evomat'
        )

    def __init__(self, rule_num):
        
        self.rule = rule_num
        #possible configurations
        configurations = (
            (1, 1, 1),
            (1, 1, 0),
            (1, 0, 1),
            (1, 0, 0),
            (0, 1, 1),
            (0, 1, 0),
            (0, 0, 1),
            (0, 0, 0)
        )

        #convert rule to bibase to list
        rule = tuple(i for i in f'{rule_num:08b}')

        #dictiobase instance that tells us how to map the transformation
        #key is configuration and value is the respective rule
        self.transition_rule = {i:j for i, j in zip(configurations, rule)}
        self.dim, self.mat, self.evomat = None, None, None
    def matrix(self, dim):
        """initializes a square space-time matrix with each row representing a time step.
            Each row represents cells at a single point in time with time iterating with every row.


        Args:
            dim (int): dimension of matrix
        """
        self.dim = dim

        self.mat = np.zeros([dim, dim]).astype(int)
        self.mat[0, (dim - 1)//2] = 1

        self.evomat = self.mat.copy()

    def initial_state(self, initial_condition):
        """Create a random initial state for the cellular automata.

        Args:
            initial_condition (numpy array): random initial state of the cellular automata
        """
        # assert self.mat != np.zeros([self.dim, self.dim]), "initialize a matrix using .matrix(dim, dim)"
        # assert (len(initial_condition) == len(self.mat[0, :])), "length of matrix and initial state do not match"

        self.mat[0, :] = initial_condition
        self.evomat[0, :] = initial_condition

    def update(self, row):
        """Update the row time step using the user provided rule.

        Args:
            row (numpy array): current configuration of cells 

        Returns:
            new (numpy array):  new configuration of cells
        """
        new = row.copy()
        for i, _ in enumerate(row):
            if (i != 0) and (i <= self.dim-2):
                transition = self.transition_rule[tuple(row[i-1:i+2])]
                new[i] = transition
            elif i == self.dim-1:
                new[-1] = row[-1]
                #was going to wrap borders with np.roll 
                #but handled by trimming in show_evolution
            else:
                new[0] = row[0]
                #also did border wrap but handled with show_evolution
        return new

    
    def evolve_matrix(self):
        """Evolve the initial state and continue evolving each new iteration until the matrix is fully updated.
            (Note: this performs the evolution for the entire duration of time)
        """
        #assert type(self.mat) != type(None), "initialize a matrix using .matrix(dim, dim)"
        self.evomat = self.mat.copy()
        for i, row in enumerate(self.evomat[:-1, :]):
            row_copy = row.copy()
            self.evomat[i+1, :] = self.update(row_copy)
            
    def singular_update(self, i):
        """A singular update that updates the (i+1) row"""

        self.evomat[i+1, :] = self.update(self.evomat[i, :].copy())

    def show_evolution(self):
        """Display an image representing the time evolution of the system"""
        plt.imshow(self.evomat[:self.dim//2, :])
        plt.title(f'Rule {self.rule}')
        plt.show()
    
class Totalistic:
    __slots__ = \
        (
        'rule',
        'code'
        'transition_rule',
        '__dict__'
        )

    def __init__(self, rule_num, base=3):
        
        self.rule = rule_num
        self.base = base
        self.code = 3*base - 2

        rule = tuple(int(i) for i in np.base_repr(rule_num, base=base).rjust(self.code, '0'))
        self.transition_rule = {i : j for i, j in zip(reversed(range(self.code)), rule)}
        
    def matrix(self, dim):

        self.dim = dim
        self.mat = np.zeros([dim, dim]).astype(int)
        self.mat[0, (dim-1)//2] = self.base-1

        self.evomat = self.mat.copy()

    def initial_state(self, initial_condition):

        self.mat[0, :] = initial_condition
        self.evomat[0, :] = initial_condition
    
    def update(self, row):
        new = row.copy()
        for i, _ in enumerate(row):
            if (i != 0) and (i <= self.dim-2):
                transition = self.transition_rule[sum(row[i-1:i+2])]
                new[i] = transition
            elif (i == self.dim-1):
                new[-1] = row[-1] 
            else:
                new[0] = row[0]
        return new
    
    def evolve_matrix(self):
        self.evomat = self.mat.copy()
        for i, row in enumerate(self.evomat[:-1, :]):
            row_copy = row.copy()
            self.evomat[i+1, :] = self.update(row_copy)
    
    def show_evolution(self):
        plt.imshow(self.evomat[:(self.dim//2), :])
        plt.show()


if __name__ == '__main__':
    cont = True
    while cont:
        
        rule_num = int(input("Enter the rule # you'd like to see: "))
        # a = Elementary(rule_num)
        a = Totalistic(rule_num, base=3)
        #assert 0 <= rule_num <= a.base**a.code, f'{a.base}-ary rule # must satisfy : 0 <= rule # <= {a.base**a.code}'
        dim = 256
        a.matrix(dim)
        # ris = np.random.randint(2, size=dim)
        # a.initial_state(ris)
        a.evolve_matrix()
        a.show_evolution()
        
        #concatmat = a.mat
        
        # for i in range(a.dim-1):
        #     a.singular_update(i)
        #     concatmat = np.concatenate((concatmat, a.evomat), axis=0)
        # concatmat = concatmat.reshape(3*[a.dim])

        # def kth_im(u_k):
        #     plt.imshow(u_k)
        # def animate(k):
        #         kth_im(concatmat[k])
        
        # anim = FuncAnimation(plt.figure(), animate, interval=1, frames=a.dim, repeat=False)
        # plt.show()

        cont = bool(input("Any input to continue. Otherwise press Enter to quit: "))