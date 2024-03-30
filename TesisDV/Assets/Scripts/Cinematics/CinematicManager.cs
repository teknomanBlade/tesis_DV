using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;

public class CinematicManager : MonoBehaviour
{
    public GameObject cat;
    public GameObject UFOBeam;
    public AudioSource Audio;
    public PostProcessVolume volume;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    private Coroutine FadeOutSceneCoroutine;
    // Start is called before the first frame update
    void Awake()
    {
        Audio = GetComponent<AudioSource>();
        Audio.Play();
        cat.GetComponent<CatCinematicYouLose>().OnFinishCatAnim += CallFinishShaderFadeOut;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void CallFinishShaderFadeOut() 
    {
        UFOBeam.GetComponent<Animator>().SetBool("IsRetracted", true);
        //Invoke(nameof(ActiveFadeOutEffect), 3f);
    }

    public void ActiveFadeOutEffect()
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(1f));
        }
    }
    IEnumerator LerpFadeOutEffect(float duration)
    {
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }
    }
}
