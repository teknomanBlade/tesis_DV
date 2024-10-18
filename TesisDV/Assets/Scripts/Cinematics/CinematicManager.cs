using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CinematicManager : MonoBehaviour
{
    public GameObject BtnRestart, BtnBackToMainMenu;
    public AudioSource Audio;
    public PostProcessVolume volume;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    // Start is called before the first frame update

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Confined;
    }
    void Awake()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }
    

    protected void ActiveFadeInButtons()
    {
        BtnRestart.GetComponent<Animator>().SetBool("IsFadeIn", true);
        BtnBackToMainMenu.GetComponent<Animator>().SetBool("IsFadeIn", true);
    }

    
    public void BackToMainMenu() 
    {
        ActiveFadeOutEffect("BackToMainMenu");
    }

    public void Restart() 
    {
        ActiveFadeOutEffect("Restart");
    }
    public void ActiveFadeOutEffect(string buttonEffect)
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(1f, buttonEffect));
        }
    }
    IEnumerator LerpFadeOutEffect(float duration, string buttonEffect)
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
            if (buttonEffect.Equals("BackToMainMenu"))
            {
                Debug.Log("MAIN MENU");
                SceneManager.LoadScene(0);
            }
            else 
            {
                Debug.Log("RESTART");
                SceneManager.LoadScene(1);
            }
            
        }
    }
    public void ActiveFadeInEffect(float duration)
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeInSceneCoroutine != null) StopCoroutine(FadeInSceneCoroutine);
            FadeInSceneCoroutine = StartCoroutine(LerpFadeInEffect(duration));
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
}
