# DefUnit Talk

This is a code-only presentation given at the [Sydney Elixir Meetup](https://www.meetup.com/en-AU/sydney-ex/) on Wednesday 1st February 2017 about
the mucking around with Elixir types, operators and macros that lead me to
develop my first (and still experimental) hex project, [DefUnit](https://hex.pm/packages/defunit).

_Each step in the presentation is a separate commit. I used the prev/next git
aliases described [here](https://blog.jayway.com/2015/03/30/using-git-commits-to-drive-a-live-coding-session/)
to move between steps. Note there are also demo-start and demo-end tags. The commit(s)
of this README follow the demo-end - I assume you'll keep this open
in GitHub so that you can refer to it as you go through the steps in your working
directory. The action happens in `lib/defunit_talk.ex`, `lib/unit.ex` (in a later step) and 
`test/defunit_talk_test.exs`.There is also [documentation](https://hexdocs.pm/defunit/api-reference.html)
on DefUnit in hexdocs and the [README](https://github.com/robinhilliard/defunit) 
on Github._

Here is a ~~quick~~ synopsis of what I was talking about (or at least wanted to
talk about) at each commit, using the commit comments (and tag) as the title.

### piper archer stall speed (demo-start)

Erlang/Elixir relies more on pattern matching than strong typing for program
correctness, which is generally a Good Thing. However in some problem domains,
you may want to make more specific assertions, e.g:

>this is not just a float, it is an SI velocity in ms<sup>-1</sup>

What if you want these assertions to be made at compile-time? If that value is not
an SI velocity there is no useful way to recover at run time, and you don't 
want a performance overhead either.

1. If you don't care about the assertions happening at run time, try another Elixir
 project on Hex, [Unit Fun](https://hex.pm/packages/unit_fun). Congratulations! 
 You have finished the adventure.
2. If you do care about the assertions happening at compile time, continue reading

(I chose option 2) 

Some problem domains such as aerospace are even more confusing because multiple 
measurement systems are mixed together all the time. Velocity can be measured in
ms<sup>-1</sup>, knots (nautical miles per hour, actually an angular velocity at the equator), 
mph (statute miles per hour) or kph (kilometres per hour). Feet can measure the length of a 
US runway or a pressure difference from sea level in a standard atmosphere. It's no wonder
the [Mars Climate Orbiter](http://www.wired.com/2010/11/1110mars-climate-observer-report/)
programmers got confused.

## add types and specs but dialyzer gives "no local return" warning

Coming from Erlang I had read about type and spec annotations and the tool that makes use
of them to deduce type problems at compile time, [Dialyzer](http://learnyousomeerlang.com/dialyzer).
I also knew that there was a mix plugin available, [Dialyxir](https://hex.pm/packages/dialyxir),
that made it easy to run Dialyzer on Elixir programs. So I did the presumably idiomatic thing
and added types and specs to my code to see what Dialyzer said.

That's a lot of dense error message - Dialyzer did not like my code! It said `no local return` for function
`piper_archer_stall_speed()`...

> Dialyzer sucks!

Oh... `mass` and `altitude` don't have decimal points and are therefore integers, which
are passed to `stall_speed()` whose spec on line 24 expects `kg` and `feet` types for the
first and last arguments, which are declared as floats on lines 3 and 8 and therefore Dialyzer
thinks `piper_archer_stall_speed()` cannot return anything...

> No, no, we loves the precious Dialyzer!

Adding `.0` to mass and altitude clears the warning, which is gratifying. However I thought it would
be nice to have a way to say "this thing is a mass value" regardless of whether or not I
remembered to add a decimal point.

## add <~ operator to resolve dialyzer warnings

I had come across [this interesting article](http://www.rodneyfolz.com/custom-infix-functions-in-elixir/)
about how to write your own infix operators in Elixir. It would be cool to write something
like:

```
mass = 1157 <~ :kg
```

To say "this value is in kg". Then the spec for the `<~` function could say that it returned
a `kg` type, and Dialyzer would be happy... Ooh this works!

> Dialyzer... my precious! 

Now, since I'm giving a presentation this evening of my increasingly 
amazing library and the great and heroic journey of discovery I went on to create it I'll
demo how changing this to:

```
mass = 1157 <~ :feet
```

makes Dialyzer unhappy. What!? Dialyzer thinks this is perfectly ok?

> We hates the Dialyzer! We hates it and it's now suddenly and shockingly better
understood 'maximally permissive' type checking behaviour forever!!

A few learning points occurred to me at this juncture:

- I could have really done some better tests of this behaviour before releasing a library
on hex and putting my hand up for a talk (how do you check the results of running a mix
task in ExUnit?)
- The documentation mentions 'maximally permissive' type checking behaviour. Dialyzer has
seen that everything we're working with is really a float, so swapping them should be
ok, right?
- Dialyzer's strength is a concept called 'success typing' which can actually do an ok
job with no types or specs at all. In adding types and specs to my code, I suspect I brought
my OO baggage with me and expected the 'subclasses' to not be considered the same root type.

To fix this, I either need to find an alternative to Dialyzer, or somehow change Dialyzer to
support optional stronger type attributes e.g:

```
@type kg :: float, :strict
```

that would complain if a value had not explicitly been returned as that exact type from
another function.

_The first option is something I'm considering - the Path and Code modules make it easy to
crawl a project's files and read the abstract syntax trees (which include type specs, as
you'll see shortly) so it might be possible to do our own basic DefUnit style compile time checking
as a mix task._

## convert from lbs and to knots

Back in the past I had completely missed this problem, so I carried on with converting
values between units. Let's say we have the US pilot's operating handbook for a piper archer that
specifies the mass in pounds and the stall speed in knots. Our `stall speed()` function expects
SI units, and if we wanted to adapt it to work in other units we would have to go through an
error-prone process of adding coefficient fudge-factors through the formula to get the right result.

What we'd rather do is continue to write our library assuming a 'core' set of units (in our case SI,
but they could be anything) and provide a companion set of operators that quietly do our conversions
in the background without impacting our library function internals.

On line 62 we call one of these conversion helper functions:

```
mass = 2545 <~ :lbs
```

The function pattern matches the `:lbs` atom and applies a conversion factor from pounds to our 'core' mass
unit, kg:

```
@spec number <~ :lbs :: kg
def value <~ :lbs do
  value / 2.20
end
```

On line 66 we call another helper function to convert our result to knots:

```
stall_speed(mass, wing_area, coefficient_of_lift, altitude) ~> :knots 
```

which again applies the appropriate conversion factor from our core ms<sup>-1</sup> velocity units to another
velocity unit, knots, without impacting the definition of `stall_speed()`.

The specs also identify the return value types, which would be great if Dialyzer worked that way,
which it doesn't. Despite this, I really like the neat way these operators can be combined to convert values,
for instance to convert 100kmh to mph you can take advantage of left associativity and write:

```
iex> 100 <~ :kmh ~> :mph
62.13537938439514
```

## add doc tags and exdoc

Elixir has a nice documentation generation system, ExDoc. To use it, you add a reference to it in your `mix.exs`
dependencies:

```
defp deps do
   [{:ex_doc, "~> 0.13", only: :dev}]
end
```

You can provide your own documentation strings using `@typedoc` for types and `@doc` for functions, and then type
`mix docs` to generate the documentation. At this point the code for the types and conversion functions is getting
verbose, in fact it would be really good to have some compact way to describe our types and conversion factors...

## define kg unit using macro

I have used tens of programming languages over my programming career. Elixir meta-programming is something to be
properly excited about, because it gives you the program writing program flexibility of LISP without the LISP
syntax (I refused to do my last LISP assignment in my degree, because I was so over the parentheses)
and instead lets you work with the Abstract Syntax Tree (AST, nested Elixir lists and dictionaries describing parsed
Elixir code) to read and write Elixir code. Compared with macros in most languages it's like working with the browser
DOM instead of text templates to modify a web page, except that the DOM breaks down all your Javascript code as well.

A new module `Unit` defines a `core(type_id, doc_string)` macro that writes out the documentation, type and `<~` function
for us. The `quote` - `end` block is like a multiline template string that takes the Elixir code inside it and
converts it to an AST. Note that it's entirely possible to write a macro without a quote block, you just have to
return an AST structure. Inside the quote block the `unquote()` built-in lets you revert to writing AST fragments,
interpolating argument values much like `#{}` does in a string. Chris McCord (creator of Phoenix) has written a
great introduction to [Metaprogramming in Elixir](https://pragprog.com/book/cmelixir/metaprogramming-elixir)
which he used extensively to create Phoenix. You really are missing out on one of the key parts of the Elixir language 
(which is itself largely written as macros) if you don't come to grips with them.

As it is line 11 of the macro code dumps the generated Elixir code to the output so that you can see that it's
equivalent to what we had written ourselves in the previous step. Remove everything from the `|>` onwards to have
the macro return the AST instead of printing it, so that you can run the unit test.

## use DefUnit 0.4 (demo-end)

DefUnit is just a built-out version of the Unit module (Unit was already a project name on Hex), with two macros
`core` and `other` to define the types we want to work with and create corresponding conversion functions. The main
differences are the use of module attributes to communicate between the macros. The project 
[README](https://github.com/robinhilliard/defunit) describes its use.

Publishing a project on Hex is really easy (perhaps in this case _too_ easy). I followed the instructions 
[here](https://hex.pm/docs/publish) to publish DefUnit.

## Thanks!

Hope you found that interesting - you can contact me on robin [at] rocketboots.com if you have any questions, or if
you're a really good computer vision/machine learning/data science/Docker/AWS programmer type person in Sydney possibly 
looking for a job working with nice attractive people and amenable to a free cup of coffee (Oh, the shill!) :-).


