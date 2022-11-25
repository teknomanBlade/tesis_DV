using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapBase : MonoBehaviour
{
    public bool _isAvailable = true;
    private GameObject _myTrap;
    private MeshRenderer _meshRenderer;
    private Animator _anim;
    void Awake()
    {
        _meshRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();
        _anim = transform.GetChild(0).GetComponent<Animator>();
    }

    void Update()
    {
        
    }

    public void SetHighIntensity()
    {
        _anim.SetBool("IsBlueprintOver",true);
    }

    public void SetNormalIntensity()
    {
        _anim.SetBool("IsBlueprintOver", false);
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
            GameVars.Values.ShowNotification("Press 'Enter' to begin tutorial. You can also start every wave as long you've been prepared.");
    }

    public void ResetBase()
    {
        _isAvailable = false;
        _meshRenderer.enabled = true;
        _myTrap = null;
    }
}
