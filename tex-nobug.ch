This check means that string is allocated (and assigned to cur_input.name_field).
See explanation of wipet on sx where 'cur_input.name_field set to zero'.
But base_ptr is not increased if string is not allocated (TODO: find this place in
the code), so this check is not needed and hence this change is useless.

@x
case 'E': if (base_ptr > 0) if (input_stack[base_ptr].name_field >= 256) 
@y
case 'E': if (base_ptr > 0) assert(input_stack[base_ptr].name_field >= 256);
          if (base_ptr > 0)
@z

@x
if (base_ptr > 0) if (input_stack[base_ptr].name_field >= 256) 
@y
if (base_ptr > 0) assert(input_stack[base_ptr].name_field >= 256);
if (base_ptr > 0)
@z
