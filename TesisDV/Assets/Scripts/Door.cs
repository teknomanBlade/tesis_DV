using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : MonoBehaviour, IInteractable
{
    private Animator _anim;
    private float _valueToChange;

    private bool IsOpened { get; set; }
    // Start is called before the first frame update
    void Awake()
    {
        _anim = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {

    }

    IEnumerator LerpDoorAnim(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;
        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;
            _anim.SetFloat("Anim", _valueToChange);
            yield return null;
        }
        _valueToChange = endValue;
    }

    public void Interact()
    {
        if (!IsOpened)
        {
            IsOpened = true;
            StartCoroutine(LerpDoorAnim(1f,1f));
        }
        else
        {
            IsOpened = false;
            StartCoroutine(LerpDoorAnim(0f,1f));
        }
        
    }
}
