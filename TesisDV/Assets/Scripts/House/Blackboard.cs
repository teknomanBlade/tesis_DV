using System.Collections;
using System.Collections.Generic;
using UnityEditor.Experimental.GraphView;
using UnityEngine;

public class Blackboard : MonoBehaviour
{
    private Coroutine OutlineGlowCoroutine;
    private Animator _animator;
    // Start is called before the first frame update
    void Start()
    {
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void ActiveFirstExperiment()
    {
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
    }

    public void ActiveSecondExperiment() 
    {
        _animator.SetBool("IsSecondExperiment", true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    public void ActiveThirdExperiment()
    {
        _animator.SetBool("IsSecondExperiment", false);
        _animator.SetBool("IsThirdExperiment", true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    public void ActiveFourthExperiment()
    {
        _animator.SetBool("IsThirdExperiment", false);
        _animator.SetBool("IsFourthExperiment", true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    public void ActiveFifthExperiment()
    {
        _animator.SetBool("IsFourthExperiment", false);
        _animator.SetBool("IsFifthExperiment", true);
        GameVars.Values.soundManager.PlaySoundOnce("ChalkOnBlackboard", 0.8f, false);
        GameVars.Values.ShowNotification("Go check the Blackboard in your room for new Traps to Build!");
    }
    
    public void ActiveOutlineGlowEffect(float duration, float maxValue)
    {
        if (OutlineGlowCoroutine != null) StopCoroutine(OutlineGlowCoroutine);
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
