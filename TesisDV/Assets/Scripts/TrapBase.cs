using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapBase : MonoBehaviour
{
    public bool _isAvailable = true;
    private GameObject _myTrap;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void BuildOnBase()
    {
        _isAvailable = false;
        if(_myTrap != null)
        {
            Destroy(_myTrap);
        }
    }

    public void SetTrap(GameObject myTrap)
    {
        _myTrap = myTrap;
    }

    public void ResetBase()
    {
        _isAvailable = false;
        _myTrap = null;
    }
}
