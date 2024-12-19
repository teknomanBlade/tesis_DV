using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerIntro : MonoBehaviour
{
    public IntroSoundManager _introSM;
    public UFOSender _ufoSender;
    public ParticleSystem _particleSystem1;
    public ParticleSystem _particleSystem2;

    public void StartMusic()
    {
        _introSM.StartMusic();
    }

    public void SendUFO()
    {
        _ufoSender.SendUFO();
    }

    public void PauseBeam()
    {
        _particleSystem1.Pause();
        _particleSystem2.Pause();
    }

    public void ChangeScene()
    {
        SceneManager.LoadScene("MainFloor_Upgrade");
    }
}
