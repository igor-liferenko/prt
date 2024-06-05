Change 575 in mf84.bug is useless.

@x
case 'E': if (file_ptr > 0) if (input_stack[file_ptr].name_field >= 256)
@y
case 'E': if (file_ptr > 0) assert(input_stack[file_ptr].name_field >= 256);
          if (file_ptr > 0)
@z

@x
if (file_ptr > 0) if (input_stack[file_ptr].name_field >= 256) 
@y
if (file_ptr > 0) assert(input_stack[file_ptr].name_field >= 256);
if (file_ptr > 0)
@z
