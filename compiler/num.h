/* -*-Mode: c++;-*-
 Copyright 2003 John Plevyak, All Rights Reserved, see COPYRIGHT file
*/

#ifndef _num_h_
#define _num_h_

enum IF1_int_type { 
  IF1_INT_TYPE_8, IF1_INT_TYPE_16, IF1_INT_TYPE_32, IF1_INT_TYPE_64, 
  IF1_INT_TYPE_NUM
};

enum IF1_float_type { 
  IF1_FLOAT_TYPE_16, IF1_FLOAT_TYPE_32, IF1_FLOAT_TYPE_48, IF1_FLOAT_TYPE_64, 
  IF1_FLOAT_TYPE_80, IF1_FLOAT_TYPE_96, IF1_FLOAT_TYPE_112, IF1_FLOAT_TYPE_128, 
  IF1_FLOAT_TYPE_NUM
};

#define CPP_IS_LAME {{0,0,0,0,0,0,0,0}, {"uint8","uint16","uint32","uint64",0,0,0,0}, {"int8","int16","int32","int64",0,0,0,0}, {0,"float32",0,"float64",0,0,0,0}}
EXTERN char *num_type_string[4][8] EXTERN_INIT(CPP_IS_LAME);
#undef CPP_IS_LAME

#endif
