/*

  Tests of argument bundle handling for various Chapel constructs.

  Since the runtime layers might have different logic to handle
  different sizes of task/on bundles, this test ensures that they
  work as expected with a variety of sizes.
*/


config param n = 10;
config const niters = if CHPL_COMM == "none" then 1000 else 10;
config const ncoforall = 100;
config const debug = false;


// This is just a way to get an assert
// explicitly allowed for fast-on.
// It could be removed if assert is at some point
// already fast-on OK.
require "myassert.h", "myassert.c";

pragma "insert line file info"
pragma "fast-on safe extern function"
extern proc assert_match(got:int, expected:int);


proc dobegin() {

  var x: int;
  var tup: n * int;
  var order$: sync bool; // can't be inside loop?

  if debug then writeln("dobegin");

  sync {
    for i in 1..niters {
      if debug then writeln("iter ", i);

      const capture_i = i;
      x = i;
      tup[1] = i;
      tup[n] = i;

      begin {
        if debug then writeln("task 1 before wait");
        order$; // wait for order to be set below
        if debug then writeln("task 1 after wait");
        assert(x == capture_i);
        assert(tup[1] == capture_i);
        assert(tup[n] == capture_i);
      }
      
      x += 1;
      tup[1] += 1;
      tup[n] = x;

      begin {
        if debug then writeln("task 2 before wait");
        order$; // wait for order to be set below
        if debug then writeln("task 2 after wait");
        assert(x == capture_i+1);
        assert(tup[1] == capture_i+1);
        assert(tup[n] == capture_i+1);
      }

      // Modifications to x and tup at this point
      // should not affect the tasks.
      x = 0;
      tup[1] = 0;
      tup[n] = 0;

      if debug then writeln("first write");
      // Run a begin
      order$ = true;
      if debug then writeln("second write");
      // Run another begin
      order$ = true;
      if debug then writeln("after writes");
    }
    if debug then writeln("end of loop");
  }
}

proc dobeginon() {

  var x: int;
  var tup: n * int;
  var order$: sync bool; // can't be inside loop?

  if debug then writeln("dobeginon");

  sync {
    for i in 1..niters {
      if debug then writeln("iter ", i);

      const capture_i = i;
      x = i;
      tup[1] = i;
      tup[n] = i;

      begin on Locales[numLocales-1] {
        if debug then writeln("task 1 before wait");
        order$; // wait for order to be set below
        if debug then writeln("task 1 after wait");
        assert(x == capture_i);
        assert(tup[1] == capture_i);
        assert(tup[n] == capture_i);
      }
      
      x += 1;
      tup[1] += 1;
      tup[n] = x;

      begin on Locales[numLocales-1] {
        if debug then writeln("task 2 before wait");
        order$; // wait for order to be set below
        if debug then writeln("task 2 after wait");
        assert(x == capture_i+1);
        assert(tup[1] == capture_i+1);
        assert(tup[n] == capture_i+1);
      }

      // Modifications to x and tup at this point
      // should not affect the tasks.
      x = 0;
      tup[1] = 0;
      tup[n] = 0;

      if debug then writeln("first write");
      // Run a begin
      order$ = true;
      if debug then writeln("second write");
      // Run another begin
      order$ = true;
      if debug then writeln("after writes");
    }
    if debug then writeln("end of loop");
  }
}

proc doon() {

  var x: int;
  var tup: n * int;

  if debug then writeln("doon");

  for i in 1..niters {
    if debug then writeln("iter ", i);

    const capture_i = i;
    x = i;
    tup[1] = i;
    tup[n] = i;
    const tup_copy = tup; 

    on Locales[numLocales-1] {
      assert(x == capture_i);
      assert(tup[1] == capture_i);
      assert(tup[n] == capture_i);
      assert(tup_copy[1] == capture_i);
      assert(tup_copy[n] == capture_i);
    }
    
    // Modifications to x and tup at this point
    // should not affect the tasks.
    x = 0;
    tup[1] = 0;
    tup[n] = 0;
  }
  if debug then writeln("end of loop");
}


proc dofaston() {

  var x: int;
  var tup: n * int;

  if debug then writeln("dofaston");

  for i in 1..niters {
    if debug then writeln("iter ", i);

    const capture_i = i;
    x = i;
    tup[1] = i;
    tup[n] = i;
    const tup_copy = tup; 

    on Locales[numLocales-1] {
      assert_match(x, capture_i);
      assert_match(tup_copy[1], capture_i);
      assert_match(tup_copy[n], capture_i);
    }
    
    // Modifications to x and tup at this point
    // should not affect the tasks.
    x = 0;
    tup[1] = 0;
    tup[n] = 0;
  }
  if debug then writeln("end of loop");
}

proc defastbeginon() {

  var x: int;
  var tup: n * int;

  if debug then writeln("defastbeginon");

  for i in 1..niters {
    if debug then writeln("iter ", i);

    const capture_i = i;
    x = i;
    tup[1] = i;
    tup[n] = i;
    const tup_copy = tup; 

    begin on Locales[numLocales-1] {
      assert_match(x, capture_i);
      assert_match(tup_copy[1], capture_i);
      assert_match(tup_copy[n], capture_i);
    }
    
    // Modifications to x and tup at this point
    // should not affect the tasks.
    x = 0;
    tup[1] = 0;
    tup[n] = 0;
  }
  if debug then writeln("end of loop");
}




/* This could be commented out once bug.chpl is fixed
iter modifyAndYield(num:int, i: int, ref x: int, ref tup: n*int)
{
  for j in 1..num {
    const tmp = 1000*i + j;
    x = tmp;
    tup[1] = tmp;
    tup[n] = tmp;
    if debug then writeln("Yielding ", j, " x=", x);
    yield j;
  }
}

proc docoforall() 

  var x: int;
  var tup: n * int;
  var order$: sync bool; // can't be inside loop?

  if debug then writeln("docoforall");

  sync {
    for i in 1..niters {
      if debug then writeln("iter ", i);
      const capture_i = i;

      coforall j in modifyAndYield(ncoforall, i, x, tup) {
        var tmp = 1000*capture_i + j;
        if x != tmp {
          writeln("Task i=", i, " j=", j, " got tmp ", tmp, " x=", x);
        }
        assert(x == tmp);
        assert(tup[1] == tmp);
        assert(tup[n] == tmp);
      }
    }
    if debug then writeln("end of loop");
  }
}
*/

dobegin();
dobeginon();
doon();
dofaston();
defastbeginon();
//docoforall();

writeln("OK");
