# shrink-whitespace package

[![Build Status](https://travis-ci.org/jcpetkovich/atom-shrink-whitespace.svg?branch=master)](https://travis-ci.org/jcpetkovich/atom-shrink-whitespace)

This package is a port of my [shrink-whitespace.el](https://github.com/jcpetkovich/shrink-whitespace.el) package from Emacs to atom. I did this as an experiment to see how easy it was to develop atom packages, and what the API was like.

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)

`shrink-whitespace` is a DWIM whitespace removal key for emacs. The behaviour is
pretty simple, but I haven't found anything else that does what I want.

# Usage

Consider the following scenario, point represented by (|):

```
Here is some text


(|)



Here is some more text
```

When you invoke `shrink-whitespace`, the whitespace between the lines is reduced
to a single line like so:

```
Here is some text
(|)
Here is some more text
```

If you want to remove further whitespace, just invoke it again:

```
Here is some text
(|)Here is some more text
```

Now there is no space between the two lines, and point is at the beginning of
the second line.


This same function works with horizontal space, and uses the same general logic.
Consider the following scenario:

```c
int main(int argc,     (|) char *argv[])
{

	return 0;
}
```

Invoking `shrink-whitespace` removes the extra whitespace around point:

```c
int main(int argc, (|)char *argv[])
{

	return 0;
}
```

And can be invoked again:

```c
int main(int argc,(|)char *argv[])
{

	return 0;
}
```

That's really all there is to it, but I find it remarkably useful, and use it
every single day.
