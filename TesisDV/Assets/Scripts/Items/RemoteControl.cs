using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RemoteControl : Remote
{
    // Start is called before the first frame update
    void Awake()
    {
        _as = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public override void ActivatableAction()
    {
        anim.SetBool("IsTurnOnOff", true);
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

    }

    public void ActiveSound()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as, "RemoteControl_On_Off", 0.08f, true);
    }

    public void SetIdle()
    {
        anim.SetBool("IsTurnOnOff", false);
    }

    private void OnTriggerStay(Collider other)
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
        
    }

}
