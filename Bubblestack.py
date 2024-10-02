# Python3 program for bubble sort 
# using stack 

# Function for bubble sort using Stack 
def bubbleSortStack(a, n):
	s1 = []
	
	# Push all elements of array in 1st stack
	for i in range(n):
		s1.append(a[i]);
	s2 = []
	for i in range(n):
		if (i % 2 == 0):
			while (len(s1) != 0):
				t = s1[-1]
				s1.pop();
				if(len(s2) == 0):
					s2.append(t);				 
				else:
				
					# Swapping
					if (s2[-1] > t):
						temp = s2[-1]
						s2.pop();
						s2.append(t);
						s2.append(temp);
					
					else:
						s2.append(t);
					
			# Tricky step
			a[n - 1 - i] = s2[-1]
			s2.pop();		 
		else:
		
			while(len(s2) != 0):
				t = s2[-1]
				s2.pop();

				if(len(s1) == 0):
					s1.append(t);
				else:
					if (s1[-1] > t):
						temp = s1[-1]
						s1.pop();

						s1.append(t);
						s1.append(temp);
					else:
						s1.append(t);
					
			# Tricky step
			a[n - 1 - i] = s1[-1]
			s1.pop();
	print("[", end = '')
	for i in range(n):
		print(a[i], end = ', ')
	print(']', end = '')

# Driver code
if __name__=='__main__':
	
	a = [ 15, 12, 44, 2, 5, 10 ]
	n = len(a)

	bubbleSortStack(a, n);
	
	# This code is contributed by rutvik_56.
