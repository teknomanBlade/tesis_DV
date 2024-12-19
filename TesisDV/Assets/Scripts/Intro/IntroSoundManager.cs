using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IntroSoundManager : MonoBehaviour
{
    [SerializeField] private AudioSource _as;
    //[SerializeField] private SoundManager _sm;

    public void StartMusic()
    {
        //_sm.PlaySound(_as, "SFX_UFOSpookyMusicWaves", 0.12f, true, 0f);
        _as.Play();
    }
}
