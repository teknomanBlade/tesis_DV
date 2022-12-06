using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapBase : MonoBehaviour
{
    public bool _isAvailable = true;
    public GameObject ArrowIndicator;
    private GameObject _myTrap;
    private MeshRenderer _meshRenderer;
    private Animator _anim;
    void Awake()
    {
        //ArrowIndicator.SetActive(false);
        _meshRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();
        _anim = transform.GetChild(0).GetComponent<Animator>();
    }

    void Update()
    {
        
    }

    public void SetHighIntensity()
    {
        if(_isAvailable)
            ArrowIndicator.SetActive(true);

        _anim.SetBool("IsBlueprintOver",true);
    }

    public void SetNormalIntensity()
    {
        if (!_isAvailable)
            ArrowIndicator.SetActive(false);

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
        ArrowIndicator.SetActive(false);
        if (gameObject.tag.Equals("Tutorial"))
            GameVars.Values.ShowNotification("Press 'Enter' to begin tutorial. You can also start every wave as long you've been prepared.");
    }

    public void ResetBase()
    {
        _isAvailable = false;
        ArrowIndicator.SetActive(true);
        _meshRenderer.enabled = true;
        _myTrap = null;
    }
}
