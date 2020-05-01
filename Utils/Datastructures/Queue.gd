extends Node

var queue = [];
var max_size = 0;
var head = 0;
var tail = 0;

# Set queue size and optionally initialize with value
func init(n, x=0):
	max_size = n;
	for i in range(n):
		queue.append(x);
		
func size():
	return tail - head;

func is_full():
	return tail == max_size;

func is_empty():
	return head == tail;
	
func push(x):
	if is_full():
		print("Queue is full");
		return false;
	else:
		queue[tail] = x;
		tail = tail + 1;
		return true;
		
func front():
	if is_empty():
		print("Queue is empty");
	else:
		return queue[head];

func pop():
	if is_empty():
		print("Queue is empty");
	else:
		var x = queue[head];
		head += 1;
		return x;
		
func clear():
	tail = 0
	head = tail

func back():
	if is_empty():
		print("Queue is empty")
	else:
		return queue[tail];
