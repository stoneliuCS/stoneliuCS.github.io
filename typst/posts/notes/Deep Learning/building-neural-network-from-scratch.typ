#metadata((
  title: "Building a Neural Network from scratch in Go",
  date: "2026-06-17",
  description: "Exploring perceptrons, sigmoids, feedforward, and backpropogation.",
  featured: true,
)) <post-meta>

#import "../../../lib/web.typ": aside, draw-net
#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot
#import "@preview/neural-netz:0.3.0": *

#aside[
  You can view the source code for this project #link("https://github.com/stoneliuCS/goat")[here] on my github.
]
== Neural Networks
Neural Networks have always been quite mysterious to me, even after learning about them in school I could not fully grasp how the inner machinery of the network learned arbitrary tasks such as image classification. So like any normal person ought to do, I decided I would take on the task of building it completely from scratch myself using this #link("http://neuralnetworksanddeeplearning.com/chap1.html")[book].

== The Perceptron
I first started out by modeling a _perceptron_, its a type of neuron that takes as input several bits $x_1, x_2, dots, x_n$ and produces a binary output $0$ or $1$. We can take each of the inputs to our neuron and add a _threshold_ which determines if the neuron _activates_ or not. The _weight_ to each input represents the _importance_ of the input. This can be formalized as the following rule:
$
  phi = cases(
    0 "if" Sigma_j w_j x_j lt.eq "threshold",
    1 "if" Sigma_j w_j x_j gt "threshold",
  )
$
Notice that if we assign the _threshold_ value a name such as $b$ and move it to the other side of the inequality we get

$
  phi = cases(
    0 "if" Sigma_j w_j x_j + b lt.eq 0,
    1 "if" Sigma_j w_j x_j + b gt 0,
  )
$

And finally if we replace the $Sigma_j w_j x_j$ with vectors to represent the weights and features as $W$ and $x$ then we can get the familiar formula

$
  phi = cases(
    0 "if" W x + b lt.eq 0,
    1 "if" W x + b gt 0,
  )
$

In code, I represented my perceptron as such:
```go
type Perceptron struct {
	threshold float64
  // Number of inputs the perceptron is allowed to take.
	inputs    uint
}

func CreatePerceptron(threshold float64, inputSize uint) *Perceptron {
	return &Perceptron{
		threshold: threshold,
		inputs:    inputSize,
	}

}

// Input is a single binary input together with its weight.
type Input struct {
	X uint8
	W float64
}
```
Whats interesting about perceptrons is that it can serve as a universal model for computation. For instance you can create a *NAND* gate by taking two binary inputs each with a weight of $-2$ and a bias of $3$.


```go
func NAND(x1 uint8, x2 uint8) uint8 {
  // 3 is the bias and 2 is the number of inputs
	p1 := CreatePerceptron(3, 2)
	return p1.Forward(Input{X: x1, W: -2}, Input{X: x2, W: -2})
}
```

Why do the weights equaling $-2$ and a bias of $3$ represent a *NAND* network? Lets do the math. *NAND* is simply a logical operator with the following truth table

#figure(
  table(
    columns: 3,
    align: center,
    stroke: 0.5pt + luma(200),
    table.header([$x_1$], [$x_2$], [NAND]),
    [0], [0], [1],
    [0], [1], [1],
    [1], [0], [1],
    [1], [1], [0],
  ),
)

#figure(
  draw-net(
    (2, 1),
    node-labels: (($x_1$, $x_2$), ($y$,)),
    edge-labels: (i, a, b) => $-2$,
  ),
)

$
  x_1 = 0, x_2 = 0 => mat(
    -2, -2;
    delim: "["
  ) mat(0; 0; delim: "[") + 3 = z = 3 => y = phi(3) = 1
$

$
  x_1 = 0, x_2 = 1 => mat(
    -2, -2;
    delim: "["
  ) mat(0; 1; delim: "[") + 3 = z = 1 => y = phi(1) = 1
$

$
  x_1 = 1, x_2 = 0 => mat(
    -2, -2;
    delim: "["
  ) mat(1; 0; delim: "[") + 3 = z = 1 => y = phi(1) = 1
$

$
  x_1 = 1, x_2 = 1 => mat(
    -2, -2;
    delim: "["
  ) mat(1; 1; delim: "[") + 3 = z = -1 => y = phi(-1) = 0
$

You can also model other functions such as *XOR* by building a network of *NAND* perceptrons. However the problem with perceptrons is that it can never truly learn, the activations are all linear and thus can only learn linear relationships and nothing more complex.

== The Sigmoid Neuron
The sigmoid neuron is the defacto standard when first learning artificial neural networks. It solves the problem of the _Perceptron_, since the activations are all step functions and composing such a network of perceptrons could only truly learn _linear_ relationships. It is defined to be
$
  sigma(x) = frac(1, 1 + e^(-x))
$
The nice thing about the sigmoid is that it looks something like this:

#figure(
  cetz.canvas({
    plot.plot(
      size: (12, 7),
      x-tick-step: none,
      x-ticks: (-8, -6, -4, -2, 2, 4, 6, 8),
      y-tick-step: none,
      y-ticks: (0.25, 0.5, 0.75, 1),
      y-min: 0,
      y-max: 1,
      axis-style: "school-book",
      {
        plot.add(
          domain: (-8, 8),
          samples: 120,
          x => 1 / (1 + calc.exp(-x)),
        )
      },
    )
  }),
)

Notices that the _sigmoid_ squashes all $x in RR$ to a value between the interval of $(0,1)$. This is very useful, much more useful than that of the step function given by the _Perceptron_.

#aside(
  "The step function is not the best at learning given the nature of its definition. You can see that the graph itself is either 0 or 1, meaning the gradient is always 0.",
)
#figure(
  cetz.canvas({
    plot.plot(
      size: (12, 7),
      x-tick-step: none,
      x-ticks: (-8, -6, -4, -2, 2, 4, 6, 8),
      y-tick-step: none,
      y-ticks: (1,),
      y-min: -0.3,
      y-max: 1.3,
      axis-style: "school-book",
      {
        plot.add(domain: (-8, 0), samples: 2, x => 0, style: (stroke: blue))
        plot.add(domain: (0, 8), samples: 2, x => 1, style: (stroke: blue))
      },
    )
  }),
)


Of course there are still many use cases for the perceptron, however our goal is to classify digits in which is not a binary problem. Let's walk through an example neural network to get a sense of the differences of the activations.

#figure(
  draw-net(
    (3, 2),
    node-labels: (($x_1$, $x_2$, $x_3$), ($a_1$, $a_2$)),
    edge-labels: (i, a, b) => $w_(#(b + 1) #(a + 1))^(#(i + 2))$,
  ),
)

#aside[
  This was the one of the more confusing parts of neural networks was how the
  weights, biases, features, and activations were all related to one another. We
  can think of the $i$-th row in our weight matrix $W$ as representing all the
  connections coming into the $i$-th neuron of that layer.
]

I will be using #link("http://neuralnetworksanddeeplearning.com/chap2.html")[Nielson's Notation] since I am following along his book. If we were to compute the output of this network in a single matrix multiplication we would have the following

$
  W = mat(
    w_(11)^2, w_(12)^2, w_(13)^2;
    w_(21)^2, w_(22)^2, w_(23)^2;
    delim: "["
  ),
  x = mat(
    x_1;
    x_2;
    x_3;
    delim: "["
  ),
  b = mat(
    b_1;
    b_2;
    delim: "["
  )
$
$
  W x + b = z = mat(
    w_(11)^2 x_1 + w_(12)^2 x_2 + w_(13)^2 x_3 + b_1;
    w_(21)^2 x_1 + w_(22)^2 x_2 + w_(23)^2 x_3 + b_2;
    delim: "["
  )
$

The output of the equation is $z$ and from there we would apply our activations to get $a$.

$
  a = mat(
    sigma(w_(11)^2 x_1 + w_(12)^2 x_2 + w_(13)^2 x_3 + b_1);
    sigma(w_(21)^2 x_1 + w_(22)^2 x_2 + w_(23)^2 x_3 + b_2);
    delim: "["
  ) = mat(
    a_1;
    a_2;
    delim: "["
  )
$

Passing the output of each layer _forward_ is what we call _Feedforward_ networks.

```go
type Network[N Number] struct {
	sizes                       []uint       // Represents the number of nodes in each layer.
	layers                      uint         // Layers not including the input layer.
	biases                      []*Vector[N] // Biases for each layer represented as column vectors
	weights                     []*Matrix[N]
	activations                 []*Vector[N] // a_l
	preActivations              []*Vector[N] // z_l
	activationFunctionsPerLayer []Activation[N]
}
func (this *Network[T]) Forward(input *Vector[T]) *Vector[T] {
	var currentFeatures = input
	for layerIdx := range this.layers {
		biasVector := this.biases[layerIdx]
		weights := this.weights[layerIdx]
		z_l := weights.Multiply(currentFeatures).Add(biasVector)
		this.preActivations[layerIdx] = z_l
		activation := this.activationFunctionsPerLayer[layerIdx]
		a_l := activation.Apply(z_l)
		this.activations[layerIdx] = a_l
		currentFeatures = a_l
	}
	return currentFeatures
}
```

== Backpropogation
After building out the feedforwarding for my network, now its time to implement the basis of how neural networks actually _learn_. Say we have the following network architecture, courtesy of #link("https://www.youtube.com/watch?v=aircAruvnKk&vl=en")[3Blue1Brown]

#figure(
  draw-net(
    (
      (head: 3, tail: 1), // 784 inputs
      (head: 3, tail: 1), // hidden, 16
      (head: 3, tail: 1), // hidden, 16
      (head: 3, tail: 1), // 10 outputs
    ),
    node-labels: (
      ($x_1$, $x_2$, $x_3$, $x_784$),
      ($a_1^2$, $a_2^2$, $a_3^2$, $a_16^2$),
      ($a_1^3$, $a_2^3$, $a_3^3$, $a_16^3$),
      ($a_1^4$, $a_2^4$, $a_3^4$, $a_(10)^4$),
    ),
  ),
)

I have represented this network as an object:
```go
sizes := []uint{784, 16, 16, 10}
activations := []nn.Activation[float64]{
  nn.SigmoidActivation[float64](), // Activations at each layer
  nn.SigmoidActivation[float64](),
  nn.SigmoidActivation[float64](),
}
network := nn.CreateNetwork(sizes, activations)
```

When training a neural network to learn how to classify digits, we will take the output or prediction of the final layer and compare it with the ground truth. We model how accurate the prediction of our model is using something called a _Loss Function_. For simplicity, we will be using the mean squared error to capture how close or far out our network is from the ground truth.
$
  C = frac(1, n) sum_(i = 1)^n (y_i - hat(y)_i)^2
$
In code I have represented it as such:
```go
type MSE[N Number] struct{}

func (this *MSE[N]) Cost(prediction, target *Vector[N]) N {
	n := prediction.rows
	var sum float64 = 0

	for i := range n {
		gt := prediction.Get(i, 0)
		pred := target.Get(i, 0)
		sum += math.Pow(float64(gt-pred), 2)
	}
	return N(sum / float64(n))
}
```
So far I have gotten the following:
1. Defined the network architecture _$(728 times 16 times 16 times 10)$_.
2. Implemented feedforward with the sigmoid activation function.
3. Implement Backpropogation ?
To do this at a very high level we want to be able to find what weights and biases in our network that we can tweak such that we minimize our loss function. But what does it mean to minimize our loss function?

This is where calculus comes in handy because there is a technique called _Gradient Descent_ in which we can use it to find local minimums. We will update each of the weights and biases of our network with the following rule:

$
  w^l = w^l - alpha frac(partial C, partial w^l)
$

$
  b^l = b^l - alpha frac(partial C, partial b^l)
$

But what is $frac(partial C, partial w^l)$ and $frac(partial C, partial b^l)$? Let us consider the final layer of our network, $l = 4$. We know that in the final layer the preactivation value $z_4$ is equal to

=== The Gradient of the Cost Function With Respect to the Weights
$
  z^4 = W^4 a^3 + b^4 => sigma(z^4) = a^4 = mat(
    a_1^4;
    a_2^4;
    a_3^4;
    dots.v;
    a_(10)^4;
    delim: "["
  )
$
It's quite easy to get lost in the sea of notation, but a neural network is simply made up of a bunch of composite functions. So lets think about this in the classical chain rule from calculus.
$
  x = w^l \
  h(x) = z^l = w^l a^(l - 1) + b^l \
  g(h(x)) = a^l = sigma(z^l) \
  f(g(h(x))) = C^l (a^l) = frac(1, n) sum_(i = 1)^n (y_i - a^l_i)^2 \
$
So what is $frac(partial f, partial x)$? Well the chain rule tells us its
$
  frac(partial f, partial x) = frac(partial f, partial g) dot frac(partial g, partial h) dot frac(partial h, partial x)
$
Now replacing $f = C$, $g = a^l$, $h = z^l$, and $x = w^l$ we have
$
  frac(partial C, partial w^l) = frac(partial C, partial a^l) dot frac(partial a^l, partial z^l) dot frac(partial z^l, partial w^l)
$
But notice what is $frac(partial a^l, partial z^l)$? We know that the activations in our neural network is precisely $frac(partial a^l, partial z^l) = sigma ' (z^l)$ the derivative of the sigmoid. The derivative of the sigmoid is
$
  frac(partial a^l, partial z^l) = sigma ' (z^l) = sigma(z^l) dot (1 - sigma(z^l))
$
Furthermore we can easily calculate $frac(partial z^l, partial w^l)$ to be
$ frac(partial z^l, partial w^l) = a^(l - 1) $
So we finally have that
$
  frac(partial C, partial w^l) = frac(partial C, a^l) dot.circle sigma(z^l) dot (1 - sigma(z^l)) dot a^(l-1)
$
By convention we set
$ delta^l = frac(partial C, a^l) dot.circle sigma(z^l) dot (1 - sigma(z^l)) $
So we can finally get the famous
$
  frac(partial C, partial w^l) = delta^l dot a^(l - 1)
$

=== The Gradient of the Cost Function With Respect to the Bias
Similarily we can compute the gradient with respect to the _bias_ term $b$. If we follow the _chain rule_ again we can see that

$
  frac(partial C, partial b^l) = frac(partial C, partial a^l) dot frac(partial a^l, partial z^l) dot frac(partial z^l, partial b^l)
$

We have already computed $frac(partial C, partial a^l)$ and $frac(partial a^l, partial z^l)$ from above and $frac(partial z^l, partial b^l) = 1$. So quite elegantly it collapses down to

$
  frac(partial C, partial b^l) = delta^l
$
```go
func (this *Network[N]) Backpropogation(input *Vector[N],
	prediction *Vector[N],
	target *Vector[N],
	loss Cost[N]) ([]*Vector[N], []*Matrix[N]) {
	// First compute the error of the prediction
	layer := int(this.layers - 1)
	derivative_of_cost_with_respect_to_L := loss.Gradient(prediction, target)
	derivative_of_activation := this.activationFunctionsPerLayer[layer].Gradient(this.preActivations[layer])
	delta := derivative_of_cost_with_respect_to_L.HadamardMultiply(derivative_of_activation)
	gradB := make([]*Vector[N], this.layers) // We store the gradients at each layer
	gradW := make([]*Matrix[N], this.layers)
  // Backpropogate the error results through the network...
```

In order to backpropogate all of our calculations we perform this iteratively. That means calculating
$
  delta^(l - 1) = frac(partial C, a^(l - 1)) dot.circle sigma(z^(l - 1)) dot (1 - sigma(z^(l - 1)))
$
```go
// remaining function
	for layer >= 0 {
		gradB[layer] = delta
		var inActivations *Vector[N]
		if layer-1 < 0 {
			inActivations = input
		} else {
			inActivations = this.activations[layer-1]
		}
		weightGrad := delta.Multiply(inActivations.Transpose())
		gradW[layer] = weightGrad
		if layer > 0 {
			wTransposeDelta := this.weights[layer].Transpose().Multiply(delta)
			activationGradient := this.activationFunctionsPerLayer[layer-1].Gradient(this.preActivations[layer-1])
			delta = wTransposeDelta.HadamardMultiply(activationGradient)
		}
		layer -= 1
	}
	return gradB, gradW
```

That's it! We achieve approximately $95 percent$ accuracy on the _MNIST_ test dataset.

== Resources
- #link(
    "http://neuralnetworksanddeeplearning.com/",
  )[Neural Networks and Deep Learning]
- #link(
    "https://medium.com/binaryandmore/beginners-guide-to-deriving-and-implementing-backpropagation-e3c1a5a1e536",
  )[Backpropogation Derivation]
- #link(
    "https://www.youtube.com/watch?v=aircAruvnKk&vl=en",
  )[3Blue1Brown Deep Learning]
