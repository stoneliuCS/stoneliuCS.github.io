#metadata((
  title: "Building a Neural Network from scratch in Go",
  date: "2026-06-17",
  section: "notes",
  topic: "Deep Learning",
)) <post-meta>

#import "/lib/web.typ": aside

== Neural Networks
Neural Networks have always been quite mysterious to me, even after learning about them in school I could not fully grasped how the inner machinery of the network learned arbitrary tasks such as image classification. So like any normal person sought to do, I decided I would take on the task of building it completely from scratch myself using this #link("http://neuralnetworksanddeeplearning.com/chap1.html")[book].

== Data Modeling
I first started out by modeling a _perceptron_, its a type of neuron that takes as input several bits $x_1, x_2, dots, x_n$ and produces a binary output $0$ or $1$. We can take each of the inputs to our neuron and add a _threshold_ which determines if the neuron _activates_ or not. The _weight_ to each input represents the _importance_ of the input. This can be formalized as the following rule:
$
  cases(
    0 "if" Sigma_j w_j x_j lt.eq "threshold",
    1 "if" Sigma_j w_j x_j gt "threshold",
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
You can also model other functions such as *XOR* by building a network of *NAND* perceptrons. However the problem with perceptrons is that it can never truly learn, the activations are all linear and thus can only linear relationships and nothing more complex.

== The Sigmoid Neuron
The sigmoid neuron is the defacto standard when first learning artificial neural networks. It solves the problem of the _Perceptron_, since the activations there were merely a step function and composing a network of perceptrons could only truly learn _linear_ relationships.

_TBD (To Be Continued)..._
