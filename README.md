# stack_and_audio

Script that given two gifs and one audio file creates an mp4 video with the two gifs vertically stacked and the mp3 track as main audio track. The output file has the name of the first gif with the mp4 extension. It scales everything to the width of the first gif. Since it calculates the duration of the final video as  the shortest between the least common multiplier of the duration of the two gifs and the audio track, it could result in a quite big output file.

# Usage example
We use:
- Tesseract.gif - By Jason Hise at English Wikipedia - Transferred from en.wikipedia to Commons.Own work, Public Domain, https://commons.wikimedia.org/w/index.php?curid=1493225
- ACRIMSat_Animation.gif - By NASA / JPL - NASA / JPL, Public Domain, https://commons.wikimedia.org/w/index.php?curid=970812
- Loveshadow_-_Drunk_Text_1.mp3 - Drunk Text by Loveshadow, Creative Commons 3.0, http://ccmixter.org/files/Loveshadow/60070

```bash
./stack_and_audio.sh Tesseract.gif ACRIMSat_Animation.gif Loveshadow_-_Drunk_Text_1.mp3
```

It will create the file `Tesseract.mp4` with the two gifs stacked and the audio track playing. Notice the file is quite large, given the loop matching.
