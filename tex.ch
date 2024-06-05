Change 431 in tex82.bug is useless.

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
