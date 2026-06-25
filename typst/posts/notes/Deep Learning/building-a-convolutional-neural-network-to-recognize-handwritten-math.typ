#metadata((
  title: "Using CNNs to recognize Handwritten Math",
  date: "2026-06-23",
)) <post-meta>

#import "../../../lib/web.typ": aside, bookmark, toc
#import "../../../lib/drawings.typ": draw-arrays

#toc()

== Convolutional Neural Networks

In a #link("/2026/06/17/Building-a-Neural-Network-from-scratch-in-Go.html")[previous entry], I built an entire neural network from scratch to recognize digits in the _MNIST_ dataset. This time I want to dive into the exciting world of *Convolutional Neural Networks* or _CNNs_.

#aside[
  Following along this excellent resource here on the introduction to #link("https://arxiv.org/pdf/1511.08458")[Convolutional Neural Networks]

]
CNNs are essentially the same thing as the typical artifical neural networks that I have built but are much better suited for _2-dimensional_ data such as images. Apparently there is an entire labeled dataset called #link("https://arxiv.org/abs/2404.10690")[Math Writing] for this!

=== Architecture of a Convolutional Neural Network
A CNN is comprised of three types of layers. These are the convolutional layers, the pooling layers, and the fully connected layers. The input to the CNN typically has $3$ dimensions, regarding width, height, and _depth_. These I take it to be somewhat vague in terms of what they reference but for example a typical photograph has $3$ channels which reflect the *RGB* _Red, Green, and Blue_ pixel values of a colored image.

#aside[Got this line from the excellent #link("https://www.youtube.com/watch?v=KuXjwB4LzSA")[3Blue1Brown] video on the mathematical topic!]
1. *Convolutional Layer* can be thought of relating local areas of source image to the neurons of the output layer.
  - But what is a _Convolution_? It's essentially a generalized way to combine two arbitrary functions together. Yeah, not the most helpful explaination, so I want to dig further into this with you!
    - *Adding Two Random Variables* If we visualize all the possible combinations of rolling two $6$ sided die, we get that since each die has $6$ possible outcomes, we can pair each number to get $6^2 = 36$.
    - I love the visualization he creates for a convolution. Say we have two arrays of $3$ numbers each. The convolution represented as
      $
        a = (7,8,1) \
        b = (9,1,7) \
        a ast b = (7,8,1) ast (9,1,7)
      $
      can be visualized as follows:
      #figure(draw-arrays((
        (values: (7, 8, 1), label: $a$, offset: 3),
        (values: (7, 1, 9), label: $b$),
      )))
      We first reverse the corresponding elements of $b$ like so. Then we shift $b$ one block at a time.
      #figure(draw-arrays((
        (values: (7, 8, 1), label: $a$, offset: 2),
        (values: (7, 1, 9), label: $b$),
      )))
      $"We take" 7 dot 9 = 63$
      #figure(draw-arrays((
        (values: (7, 8, 1), label: $a$, offset: 1),
        (values: (7, 1, 9), label: $b$),
      )))
      $7 dot 1 plus 8 dot 9 = 7 + 72 = 79$
      #figure(draw-arrays((
        (values: (7, 8, 1), label: $a$, offset: 0),
        (values: (7, 1, 9), label: $b$),
      )))
      $7 dot 7 plus 8 dot 1 plus 1 dot 9 = 49 + 8 + 9 = 66$
      #figure(draw-arrays((
        (values: (7, 8, 1), label: $a$),
        (values: (7, 1, 9), label: $b$, offset: 1),
      )))
      $8 dot 7 plus 1 dot 1 = 56 + 1 = 57$
      #figure(draw-arrays((
        (values: (7, 8, 1), label: $a$),
        (values: (7, 1, 9), label: $b$, offset: 2),
      )))
      $7 dot 1 = 7$
      So overall $a ast b = (7,8,1) ast (9,1,7) = (63, 79, 66, 57, 7)$. To double check, _numpy_ actually has a
      convolution function built in!
      ```python
      np.convolve((7,8,1), (9,1,7))
      => [63 79 66 57 7]
      ```
    This is essentially what the concept of the _kernel_ is doing in the convolutional layers. We are dragging a lense across a set of pixels and extracting some sort of feature we want out of it. Kinda like a moving average.
2. *Pooling Layer* downsamples on the input which in turn reduces the number of parameters being passed into the activations.
3. *Fully Connected Layers* will produce class scores (if for classification) from the activations, similar to the standard feedforward neural networks.

#aside[
  I was originally going to go with #link("https://arxiv.org/abs/2201.03545")[ConvNext], but that is a more generalized pretrained model.
]
== Building a Classifier
The task of recognizing handwritten math is a complicated task, since mathematical notation can devolve into more than what is this sequence of characters, I'm going to start out with fine tuning a current pre-trained model called #link("https://arxiv.org/abs/2203.02378")[Document Image Transformer]. Lets examine and read what this type of model does.

=== Proof of Concept
To give this a go, I want to first pretrain a convolutional neural network on the Math Writing dataset. The idea is to first #link("https://en.wikipedia.org/wiki/Rasterisation")[rasterize] the _inkml_ files into two dimensional grayscale images to be passed as input to our neural network. This is essentially a bigger version of the MNIST classifier that I built previously. Only this time our input is $128 times 128$ and our output contains hundreds of potential classes to mark the symbols.

#figure(
  image("/assets/img/samples.png", width: 30em),
)
Okay so first lets convert all the inkml files in the dataset into two lists, one holds the raw grayscale values for each character input, and the other holds the ground truth label.
```python
def inkml_to_image_and_label(data_path: Path):
    imgs, labels = [], []
    for sym in iter_symbols(data_path):
        if sym.strokes and sym.label:
            imgs.append(rasterize(sym.strokes, size=IMG_SIZE, line_width=STROKE_SIZE))
            labels.append(sym.label)
    return imgs, labels
```
I have gone for image sizes of $128 times 128$ and a stroke size of $3$ pixels wide.

#bookmark(
  date: "Wednesday June 24",
)[Taking a deeper dive into #link("/2026/06/25/What-are-Transformers.html")[Transformers] before continuing.]
