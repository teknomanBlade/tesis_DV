using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IntroSoundManager : MonoBehaviour
{
    [SerializeField] private AudioSource _as;

    public void StartMusic()
    {
        _as.Play();
    }
}
