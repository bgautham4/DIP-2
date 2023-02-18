#Custom type ENode. Is a representation of the nodes formed in the huffman encoding tree.
mutable struct ENode
	symbol::Integer
	p_node::Real
	encoded_val::String
	prev_node1::Union{ENode,Nothing}
	prev_node2::Union{ENode,Nothing}
end

#This function defines how to construct my custom ENode type when not specifying the encoded value (Autofills encoded_val = 0).
function ENode(symbol::Integer,prob::Real, prev_node1::Union{ENode,Nothing}, prev_node2::Union{ENode,Nothing})
	ENode(symbol,prob,"0",prev_node1,prev_node2)
end

#This function must be implemented so that the "print" function can be used on custom type ENode.
function Base.show(io::IO, x::ENode)
	println(io,"symbol = $(x.symbol) | prob = $(x.p_node) | encoding = $(x.encoded_val)")
end

#Form the initial nodes of the huffman encoding tree by using the symbol and its probabilities. 
#This function returns an array of ENodes.
function init_nodes(symbol_probs::Vector)
	sorted_symbol_probs = sort(symbol_probs, by = x->x[2], rev=true)
	ENode_arr = Vector{ENode}()
	for (symbol,prob) in sorted_symbol_probs
		push!(ENode_arr,ENode(symbol,prob,nothing,nothing))
	end
	return ENode_arr
end

#You input the initialized nodes into this function. This function forms the huffman encoding tree recursively. 
#We create a new array of nodes with each new node linking to its parent node. 
#The last 2 nodes of the node array are treated differently. 
#Their probabilities must be added up and the new node resulting from them must link back to both its parent nodes. 
#At the end of this functions execution, you will recieve the last two nodes of the encoding tree stored in an array.
function encoding_tree(nodes::Vector{ENode})
	if length(nodes) == 2
		nodes = sort(nodes,by = x->x.p_node,rev=true)
		nodes[1].encoded_val = "0"
		nodes[2].encoded_val = "1"
		return nodes
	else
		new_nodes = Vector{ENode}()
		for node_indx in 1:length(nodes) - 2
			node = nodes[node_indx]
			push!(new_nodes,ENode(node.symbol,node.p_node,node,nothing))
		end
		last_node = nodes[end]
		last_2_node = nodes[end-1]
		p_new_node = round(last_node.p_node + last_2_node.p_node, digits = 5)#Round the sum of the 2 nodes to prevent floating point sum errors.
		symbol_new_node = last_node.symbol * last_2_node.symbol
		push!(new_nodes,ENode(symbol_new_node,p_new_node,last_2_node,last_node))
		sort(new_nodes, by = x->x.p_node, rev = true) |> encoding_tree
	end
end

#Use the encoding tree to assign the encoded values to the nodes until you reach the base(init) nodes.
#The function can be thought of as follows:
#1)Make an empty queue, enqueue the 2 nodes resulting from "encoding_tree".
#2)Dequeue a node from the queue, look at its parent nodes. Assign encodings to its parent nodes by using the child nodes encoding value.
#3)Enqueue the node's parent(s) into the queue.
#4)Continue steps 2 and 3 till the queue is empty.
#This function does not return anything and the nodes created by "init_nodes" must have their respective encodings assigned at the end of its execution.
function assign_encoding(nodes::Vector{ENode})
	nodes_upd = copy(nodes)
	while length(nodes_upd) != 0
		nodes = copy(nodes_upd)
		for node in nodes
			prev_node1 = node.prev_node1
			prev_node2 = node.prev_node2
			if (~isequal(prev_node1,nothing) && isequal(prev_node2,nothing))
				prev_node1.encoded_val = node.encoded_val
				push!(nodes_upd,prev_node1)
			end

			if (~isequal(prev_node1,nothing) && ~isequal(prev_node2,nothing))
				prev_node1.encoded_val = (node.encoded_val * "0")
				push!(nodes_upd,prev_node1)
				prev_node2.encoded_val = (node.encoded_val * "1")
				push!(nodes_upd,prev_node2)
			end
			
			nodes_upd = filter(x -> ~isequal(node,x),nodes_upd)
		end
	end
end

#Huffman encoding of the symbols given their probabilities using the above functions.
function huffman_encoding(symbol_probs::Vector)
	nodes = init_nodes(symbol_probs)
	nodes |> encoding_tree |> assign_encoding
	encoding_table = Dict()
	for node in nodes
		encoding_table[node.symbol] = node.encoded_val
	end
	return encoding_table
end

#Given the encoding, find its corresponding symbol.
function find_key(encoding_table::Dict, value::String)
	for (key,val) in encoding_table
		val == value ? (return key) : continue
	end
	return nothing
end

#Encode a sequence using its encoding table.
function encode_sequence(encoding_table::Dict, sequence::Vector)
	encoded_seq = ""
	for symbol in sequence
		encoded_seq = encoded_seq * encoding_table[symbol]
	end
	return encoded_seq
end

#Decode the sequence of bits given its encoding table.
function decode_sequence(seq::String,encoding_table::Dict)
	decoded_seq = Vector{Integer}()
	L = length(seq)
	i=1
	j=0
	while(i<=L)
		if j>L
			return nothing
		end
		key = find_key(encoding_table,seq[i:i+j])
		if typeof(key)==Nothing
			j+=1
		else
			push!(decoded_seq,key)
			i = i+j+1
			j=0
		end
	end
	return decoded_seq

end
#test case
symbol_probs = [(1,0.1),(2,0.4),(3,0.06),(4,0.1),(5,0.04),(6,0.3)]
encoding_table = huffman_encoding(symbol_probs)
println(encoding_table)
encoded_seq = encode_sequence(encoding_table,[1,3,5,1,2,2,2,4,5,5,2,2,1,3,5,4,4,1])
println(encoded_seq)
decoded_seq = decode_sequence(encoded_seq,encoding_table)
println(decoded_seq)
