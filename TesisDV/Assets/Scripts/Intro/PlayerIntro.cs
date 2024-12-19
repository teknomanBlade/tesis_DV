using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;

public class PlayerIntro : MonoBehaviour
{
    public IntroSoundManager _introSM;
    public UFOSender _ufoSender;
    public ParticleSystem _particleSystem1;
    public ParticleSystem _particleSystem2;
    public PostProcessVolume volume;
    public Vignette postProcessDamage;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    public AudioSource AudioSource;
    private Camera _cam;
    public Camera Cam
    {
        get { return _cam; }
        set { _cam = value; }
    }
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    private void Start()
    {
        AudioSource = GetComponent<AudioSource>();
        Cam = GetComponentInChildren<Camera>();
        volume = Cam.GetComponent<PostProcessVolume>();
        
    }
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
    public void ClimbBox() 
    {
        AudioSource.Play();
    }
    public void ChangeScene()
    {
        ActiveFadeOutEffect();
    }
    public void ActiveFadeOutEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutRestartEffect(1f));
        }
    }
    public void ActiveFadeInEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeInSceneCoroutine != null) StopCoroutine(FadeInSceneCoroutine);
            FadeInSceneCoroutine = StartCoroutine(LerpFadeInEffect(1f));
        }
    }
    IEnumerator LerpFadeInEffect(float duration)
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
    }
    IEnumerator LerpFadeOutRestartEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }

        if (time < 0f)
        {
            SceneManager.LoadScene(1);
        }
    }
}
