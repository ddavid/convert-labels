# convert-labels (WIP)
<small> Konvertierung von Label Files in Haskel </small>

Aktuell:

- [x] BBox-label -> Darknet-label
- [ ] Darknet-label -> bbox-label

Example bbox-label:

        4
        62 493 120 570 blue-cone
        382 408 420 459 blue-cone
        1000 472 1056 559 yellow-cone
        961 402 997 451 yellow-cone
Darknet-label:

        0 0.07109375 0.738194444444 0.0453125 0.106944444444
        0 0.31328125 0.602083333333 0.0296875 0.0708333333333
        1 0.803125 0.715972222222 0.04375 0.120833333333
        1 0.76484375 0.592361111111 0.028125 0.0680555555556
