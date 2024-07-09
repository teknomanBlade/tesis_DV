using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;

public class LoadingScreen : MonoBehaviour
{
    public GameObject Cam { get; private set; }
    public float TimeCoroutine;
    public PostProcessVolume volume;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    private AsyncOperation _async;
    // Start is called before the first frame update
    void Awake()
    {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        Cam = GameObject.Find("Main Camera");
        volume = Cam.GetComponent<PostProcessVolume>();
        TimeCoroutine = 0.98f;
        StartCoroutine(LoadNewScene(1));
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator LoadNewScene(int scene)
    {
        ActiveFadeInEffect(1f);
        yield return new WaitForSeconds(2.5f);

        // Start an asynchronous operation to load the scene that was passed to the LoadNewScene coroutine.
        _async = SceneManager.LoadSceneAsync(scene);
        _async.allowSceneActivation = false;
        // While the asynchronous operation to load the new scene is not yet complete, continue waiting until it's done.

        while (!_async.isDone)
        {
            Debug.Log("PROGRESS:" + _async.progress);
            // Check if the load has finished
            if (_async.progress >= 0.9f) 
            {
                ActiveFadeOutEffect(1f);
            }
            yield return null;
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
    public void ActiveFadeOutEffect(float duration)
    {
        if (volume.profile.TryGetSettings(out postProcessFadeInOutScenes))
        {
            if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
            FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(duration));
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
    IEnumerator LerpFadeOutEffect(float duration)
    {
        while (TimeCoroutine > 0 && TimeCoroutine < duration)
        {
            TimeCoroutine -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(TimeCoroutine / duration);
            yield return null;
        }

        if (TimeCoroutine < 0f)
        {
            Debug.Log("LLEGA ACA? TIME ZERO");
            _async.allowSceneActivation = true;
        }
    }
}
