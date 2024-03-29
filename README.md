# Legendrian Knots UROP: Summer 2019
## Project Overview
An interesting extension to knot theory (which usually takes place in S3), is to spaces with the contact topology. As per [1], a good space to gain intuition for Legendrian knots (the natural extension of S3 knots into contact topology) is ℝ3 with the standard contact structure (a 3-space where non-integrable plane field which is identified to each point). In such a space, Legendrian knots — a kind of knot which is tangential to each point’s ‘plane’ — become a more geometric and much less topologically mutable, rendering many of the usual (S3) knot invariants unusable. As with usual knots, there is an invariant that arises from inspecting spaces that ‘fill’ knots, although, again, the contact topology imposes strong restrictions on what these ‘fillings’ can be. The first primary direction that this project could take is counting the number of fillings that each Legendrian knot can have. This is a difficult open problem, which my advisor has worked on (see [2]), which provides a relatively straightforward route for generalization.
The other primary direction that this research may go is into how the algebraic invariants, called augmentations (which are applied to field-like spaces), arising from these fillings corresponds to the much-easier-to-compute combinatorial Morse Complex Sequence (MCS) for cases where the augmentation is applied to spaces larger than ℤ2 (see [3]).
## Goals
The goal of this UROP is to, firstly, catch me up to speed with state-of-the-art research in contact topology, so that — secondly — I can choose between the aforementioned two primary directions. In the first, the objective would be to obtain a generalization of the work from [2] to (k,n) torus knots. In the second, the objective would be to find the relation between the augmentation and MCS for a space like ℤ, ℂ, or Mn(ℤ2).
## Compiling and Runing this project
As of 8/19/19, assuming that stack is installed, the project can be compiled using "stack build" and run with "stack exec urop-exec".
Check app/Main.hs to see what exactly will be run as this is subject to rapid change.
## References
[1] John B. Etnyre, “Legendrian AND Transversal Knots”  arXiv:math/0306256v2 [math.SG] (2004)

[2] Yu Pan, “Exact Lagrangian Fillings of Legendrian (2,n) Torus Links” arXiv:1607.03167 [math.SG] (2016)

[3] Michael B. Henry, Dan Rutherford, “Equivalence Classes of Augmentations and Morse Complex Sequences of Legendrian Knots” arXiv:1407.7003 [math.SG] (2014)
