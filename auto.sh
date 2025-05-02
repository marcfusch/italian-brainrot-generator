#!/bin/bash

# Vérification du nombre d'arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <image.jpeg> <audio.mp3> <output.mp4>"
    exit 1
fi

# Assignation des arguments à des variables
IMAGE=$1
AUDIO=$2
OUTPUT=$3
FIRE_VIDEO="assets/explosion.mov"
BACKGROUND_MUSIC="assets/music.mp3"

# Vérification de l'existence des fichiers
if [ ! -f "$IMAGE" ]; then
    echo "Erreur : Le fichier image '$IMAGE' n'existe pas."
    exit 1
fi

if [ ! -f "$AUDIO" ]; then
    echo "Erreur : Le fichier audio '$AUDIO' n'existe pas."
    exit 1
fi

if [ ! -f "$FIRE_VIDEO" ]; then
    echo "Erreur : La vidéo '$FIRE_VIDEO' n'existe pas."
    exit 1
fi

if [ ! -f "$BACKGROUND_MUSIC" ]; then
    echo "Erreur : La musique de fond '$BACKGROUND_MUSIC' n'existe pas."
    exit 1
fi

# Commande ffmpeg pour mélanger l'image, la vidéo avec chromakey, et les audios
ffmpeg -i "$IMAGE" -stream_loop -1 -i "$FIRE_VIDEO" -i "$AUDIO" -i "$BACKGROUND_MUSIC" \
-filter_complex "\
[0:v]scale=1280:720[bgimg]; \
[1:v]scale='if(gt(a,1280/720),1280,-1)':'if(gt(a,1280/720),-1,720)',chromakey=0x00FF00:0.3:0.08[ckout]; \
[bgimg][ckout]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[bg]; \
[bg]format=yuv420p[v]; \
[2:a][3:a]amix=inputs=2:duration=longest[aout]" \
-map "[v]" -map "[aout]" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -shortest "$OUTPUT"

# Vérification du succès de la commande
if [ $? -eq 0 ]; then
    echo "Fichier généré avec succès : $OUTPUT"
else
    echo "Erreur lors de la génération du fichier."
    exit 1
fi