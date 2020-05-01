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

# TODO: FIX	
func size():
	if tail >= head:
		return tail - head;
	else:
		return max_size - (head - tail);

func is_full():
	return size() == max_size - 1;

func is_empty():
	return head == tail;
	
func push(x):
	if is_full():
		print("Queue is full");
		return false;
	else:
		queue[tail] = x;
		tail = (tail + 1)%max_size;
		return true;

func pop():
	if is_empty():
		print("Queue is empty");
	else:
		var x = queue[head];
		head = (head + 1)%max_size;
		return x;

func clear():
	tail = 0
	head = tail
