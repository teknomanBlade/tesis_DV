using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class MainScreen : MonoBehaviour
{
    public GameObject controls;
    public GameObject credits;
    public GameObject houseStructure;
    public int scene;
    public GameObject Cam { get; private set; }

    public PostProcessVolume volume;
    public FadeInOutScenesPPSSettings postProcessFadeInOutScenes;
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    private AudioSource _as;
    private int _timesActiveScreen;
    // Start is called before the first frame update
    void Awake()
    {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        Cam = GameObject.Find("Main Camera");
        volume = Cam.GetComponent<PostProcessVolume>();
        _as = GetComponent<AudioSource>();
        ActiveFadeInEffect(1f);
        _timesActiveScreen++;
        Debug.Log("TIMES ACTIVE MAIN SCREEN:" + _timesActiveScreen);
    }

    // Update is called once per frame
    void Update()
    {
        
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
        float time = 0.98f;

        while (time > 0 && time < duration)
        {
            time -= Time.deltaTime;

            postProcessFadeInOutScenes._Intensity.value = Mathf.Clamp01(time / duration);
            yield return null;
        }

        if (time < 0f)
        {
            Debug.Log("LLEGO AL FINAL??");
            SceneManager.LoadScene(4);
        }
    }
    public void BtnPlay()
    {
        _as.Stop();
        ActiveFadeOutEffect(1f);
    }
    
    public void BtnControls()
    {
        Debug.Log("CLICK CONTROLS?");
        houseStructure.SetActive(false);
        controls.SetActive(!controls.activeSelf);
    }

    public void BtnCredits()
    {
        Debug.Log("CLICK CREDITS?");
        houseStructure.SetActive(false);
        credits.SetActive(!credits.activeSelf);
    }
    public void BtnBackCredits()
    {
        houseStructure.SetActive(true);
        credits.SetActive(!credits.activeSelf);
    }

    public void BtnBackControls()
    {
        houseStructure.SetActive(true);
        controls.SetActive(!controls.activeSelf);
    }
    public void BtnQuit()
    {
        Application.Quit();
    }

}
