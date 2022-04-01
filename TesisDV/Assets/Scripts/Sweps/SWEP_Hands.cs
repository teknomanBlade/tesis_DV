using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SWEP_Hands : MonoBehaviour, ISWEP
{
    public Player _player;
    private GameObject _swepModel;

    // internal
    private float range = 5f;
    private int strength = 2;
    private float force = 5f;
    private Object _currentObject;
    private bool locked = false;

    private void Update()
    {
        if (!locked) _currentObject = _player.lookingAt;
        else
        {
            KeepInFront();
        }
    }

    public void OnEquip(Player player)
    {
        _player = player;
        _swepModel = GameVars.Values.WEP_Hands;
        _swepModel.SetActive(true);
    }

    public void PrimaryFire()
    {
        if (locked)
        {
            _currentObject.Drop(_player.GetVelocity());
            Physics.IgnoreCollision(_player.GetComponent<Collider>(), _currentObject.GetComponent<Collider>(), false);
            locked = false;
            _swepModel.SetActive(true);
        }
        else if (IsInRange() && _currentObject.Grab(strength))
        {
            Physics.IgnoreCollision(_player.GetComponent<Collider>(), _currentObject.GetComponent<Collider>(), true);
            locked = true;
            _swepModel.SetActive(false);
        }
    }

    public void SecondaryFire()
    {
        if (_currentObject != null)
        {
            if (locked)
            {
                _currentObject.Push(strength, force, _player.GetCameraForward(), _player.GetVelocity());
                Physics.IgnoreCollision(_player.GetComponent<Collider>(), _currentObject.GetComponent<Collider>(), false);
                locked = false;
                _swepModel.SetActive(true);
            } else if (IsInRange())
            {
                _currentObject.Push(strength, force, _player.GetCameraForward());
            }
        }
    }

    public void Interaction()
    {
        if (!locked && !IsInRange()) return;
        _currentObject.Interaction();

    }

    public void OnUnequip()
    {
        if (locked)
        {
            _currentObject.Drop(_player.GetVelocity());
            Physics.IgnoreCollision(_player.GetComponent<Collider>(), _currentObject.GetComponent<Collider>(), false);
            locked = false;
        }
        _swepModel.SetActive(false);
    }

    // internal

    private void KeepInFront()
    {
        Vector3 pos = _player.GetCameraPosition() + _player.GetCameraForward() * _currentObject.transform.localScale.magnitude;
        Vector3 forward = -_player.GetCameraForward();
        _currentObject.SetPos(pos, forward);
    }

    private bool IsInRange()
    {
        if (_currentObject != null)
        {
            return (range >= Vector3.Distance(_player.GetCameraPosition(), _currentObject.transform.position));
        }
        else return false;
    }
}
