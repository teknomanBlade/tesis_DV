using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PBRCloakTallGray : MonoBehaviour
{
    public Animator _anim;
    public bool IsCloaked;
    // Start is called before the first frame update
    void Awake()
    {
        IsCloaked = false;
        _anim = GetComponentInChildren<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            _anim.SetBool("IsCloaked", !IsCloaked);
        }
    }

    public void SetCloaked()
    {
        IsCloaked = true;
    }

    public void SetCloakedFalse()
    {
        IsCloaked = false;
    }
}
