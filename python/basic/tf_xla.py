# Square of a vector
import tensorflow as tf
config = tf.ConfigProto(log_device_placement=True)
with tf.Session(config=config) as sess:
  x = tf.placeholder(tf.float32, [4])
  with tf.device("device:XLA_GPU:0"):
  #with tf.device("/gpu:0"):
    y = x * x
  result = sess.run(y, {x: [1.5, 0.5, -0.5, -1.5]})
  print("result is: ", result)
