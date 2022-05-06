using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Door : Item
{
    private Animator _anim;
    private float _valueToChange;

    private bool IsOpened { get; set; }
    public bool IsFront = false;
    // Start is called before the first frame update
    void Awake()
    {
        _anim = GetComponent<Animator>();
    }

    IEnumerator LerpDoorAnim(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;
        //if (IsFront) _anim.SetTrigger("TriggerFront"); else _anim.SetTrigger("TriggerBack");
        if (IsFront)
        {
            while (time < duration)
            {
                _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
                time += Time.deltaTime;

                _anim.SetFloat("Anim", _valueToChange);
                yield return null;
            }
        }
        else
        {
            while (time < duration)
            {
                _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
                time += Time.deltaTime;

                _anim.SetFloat("Blend", _valueToChange);
                yield return null;
            }
        }
        //_anim.ResetTrigger("TriggerFront"); 
        //_anim.ResetTrigger("TriggerBack");

        _valueToChange = endValue;
    }

    public override void Interact()
    {
        StopAllCoroutines();
        if (!IsOpened)
        {
            IsOpened = true;
            GameVars.Values.soundManager.PlaySoundAtPoint("OpenDoor", transform.position, 0.4f);
            StartCoroutine(LerpDoorAnim(1f, 2f));
        }
        else
        {
            IsOpened = false;
            GameVars.Values.soundManager.PlaySoundAtPoint("CloseDoor", transform.position, 0.4f);
            StartCoroutine(LerpDoorAnim(0f, 2f));
        }

    }
}

public enum EnumDoor
{
    IsPlayerBack,
    IsPlayerFront
}
