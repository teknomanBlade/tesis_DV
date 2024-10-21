using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapBase : MonoBehaviour
{
    public bool _isAvailable;
    public GameObject ArrowIndicator;
    private GameObject _myTrap;
    private MeshRenderer _meshRenderer;
    private Animator _anim;
    void Awake()
    {
        _isAvailable = true;
        _meshRenderer = transform.GetChild(0).GetComponent<MeshRenderer>();
        _anim = transform.GetChild(0).GetComponent<Animator>();
    }

    void Update()
    {
        if (transform.GetComponentInChildren<Trap>() != null)
        {
            //Debug.Log("HAS TRAP IN CHILDREN?" + (transform.GetComponentInChildren<Trap>() != null));
            ArrowIndicator.SetActive(false);
        }
        else 
        {
            //Debug.Log("HAS TRAP IN CHILDREN?" + (transform.GetComponentInChildren<Trap>() != null));
            ArrowIndicator.SetActive(true);
        }
    }
    public TrapBase SetPos(Vector3 pos) 
    {
        transform.position = pos;
        return this;
    }
    public void SetHighIntensity()
    {
        //ArrowIndicator.SetActive(!_isAvailable);

        _anim.SetBool("IsBlueprintOver",true);
    }

    public void SetNormalIntensity()
    {
        //ArrowIndicator.SetActive(_isAvailable);

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
        _isAvailable = true;
        //ArrowIndicator.SetActive(true);
        _meshRenderer.enabled = true;
        _myTrap = null;
    }
}
