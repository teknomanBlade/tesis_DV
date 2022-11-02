using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class RemoteControl : Remote
{
    private TVTrap _TVTrap;
    public TVTrap TVTrap
    {
        get { return _TVTrap; }
        set { _TVTrap = value; }
    }

    // Start is called before the first frame update
    void Awake()
    {
        _as = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    IEnumerator TurnOnOff(string param, string name)
    {
        anim.SetBool(param, true);
        var clips = anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        anim.SetBool(param, false);
    }
    public override void ActivatableAction()
    {
        StartCoroutine(TurnOnOff("IsTurnOnOff","TurnOffOnTV"));
        //anim.SetBool("IsTurnOnOff", true);
        if (IsAtRange)
        {
            Debug.Log("TURN ON TV: " + _TVTrap.IsTurnOn);
            if (_TVTrap.IsTurnOn)
            {
                _TVTrap?.TurnOff();
            }
            else
            {
                _TVTrap?.TurnOn();
            }
        }
        //Invoke("SetIdle", 0.5f);
    }

    public void ActiveSound()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as, "RemoteControl_On_Off", 0.08f, true);
    }

    public void SetIdle()
    {
        anim.SetBool("IsTurnOnOff", false);
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.GetComponent<TVTrap>() != null)
        {
            IsAtRange = true;
            _TVTrap = other.gameObject.GetComponent<TVTrap>();
            Debug.Log("AT RANGE ENTER: " + IsAtRange);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.GetComponent<TVTrap>() != null)
        {
            IsAtRange = false;
            _TVTrap = null;
            Debug.Log("AT RANGE EXIT: " + IsAtRange);
        }
    }
    /*private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.GetComponent<TVTrap>() != null)
        {
            IsAtRange = true;
            _TVTrap = other.gameObject.GetComponent<TVTrap>();
            Debug.Log("AT RANGE: " + IsAtRange);
        }
        else
        {
            IsAtRange = false;
            _TVTrap = null;
            Debug.Log("AT RANGE: " + IsAtRange);
        }
        
    }*/

}
