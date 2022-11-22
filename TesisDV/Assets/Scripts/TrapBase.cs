using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapBase : MonoBehaviour
{
    public bool _isAvailable = true;
    private GameObject _myTrap;
    private MeshRenderer _meshRenderer;
    void Awake()
    {
        _meshRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();
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
        _meshRenderer.enabled = false;
        if (gameObject.tag.Equals("Tutorial"))
            GameVars.Values.ShowNotification("Press 'Enter' to begin tutorial.");
    }

    public void ResetBase()
    {
        _isAvailable = false;
        _meshRenderer.enabled = true;
        _myTrap = null;
    }
}
