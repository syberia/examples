## Million Song dataset

Source: https://archive.ics.uci.edu/ml/datasets/YearPredictionMSD#

The goal of this model is to predict the year the song was published based on
extracted audio features.

## Attribute Information:

90 attributes, 12 = timbre average, 78 = timbre covariance
The first value is the year (target), ranging from 1922 to 2011.
Features extracted from the 'timbre' features from The Echo Nest API.
We take the average and covariance over all 'segments', each segment
being described by a 12-dimensional timbre vector.

## Data Set Information:

You should respect the following train / test split:
train: first 463,715 examples
test: last 51,630 examples
It avoids the 'producer effect' by making sure no song
from a given artist ends up in both the train and test set.
