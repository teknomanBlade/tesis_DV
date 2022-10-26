using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapBase : MonoBehaviour
{
    public bool _isAvailable = true;

    void Start()
    {
        
    }

    void Update()
    {
        
    }

    public void BuildOnBase()
    {
        _isAvailable = false;
    }
}
