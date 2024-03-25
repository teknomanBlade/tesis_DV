using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class Blackboard : MonoBehaviour
{
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine OutlineGlowCoroutine;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void ActiveFadeOutExperiment(string param, float duration, float maxValue)
    {
        if (FadeOutSceneCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
        FadeOutSceneCoroutine = StartCoroutine(LerpFadeOutEffect(param, duration, maxValue));
    }
    //Referencia 0.6f - Inicio, 0.366f Primer Experimento, 0.25f - Segundo Experimento, 0.0f - Tercer Experimento
    //Referencia SecondExperimentColumn 0.65f - Inicio, 0.23f Cuarto y Quinto Experimento
    //Referencia FourthFifth 0.54f - Inicio, 0.1f Cuarto y Quinto Experimento
    IEnumerator LerpFadeOutEffect(string param, float duration, float maxValue)
    {
        float time = maxValue;

        while (time > 0 && time > duration)
        {
            time -= Time.deltaTime;
            var value = Mathf.Clamp(time, duration, maxValue);

            GetComponent<MeshRenderer>().material.SetFloat(param, value);
            yield return null;
        }
    }
    public void ActiveOutlineGlowEffect(float duration, float maxValue)
    {
        if (OutlineGlowCoroutine != null) StopCoroutine(FadeOutSceneCoroutine);
        OutlineGlowCoroutine = StartCoroutine(LerpOutlineGlowInEffect(duration, maxValue));
    }
    IEnumerator LerpOutlineGlowOutEffect(float duration, float maxValue) 
    {
        float time = maxValue;

        while (time > 0 && time > duration)
        {
            time -= Time.deltaTime;
            var value = Mathf.Clamp(time, duration, maxValue);

            GetComponent<Outline>().OutlineWidth = value;
            yield return null;
        }
    }

    IEnumerator LerpOutlineGlowInEffect(float duration, float maxValue)
    {
        float time = 0f;

        while (time < duration)
        {
            time += Time.deltaTime;
            var value = Mathf.Lerp(time, maxValue, time/duration);
            GetComponent<Outline>().OutlineWidth = value;
            yield return null;
        }
        StartCoroutine(LerpOutlineGlowOutEffect(0f,maxValue));
    }
}
