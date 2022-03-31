using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractableStaticObject : Object
{
    public Material origMat;
    public Material changeMat;
    private MeshRenderer _mr;
    public bool active = false;

    protected override void Awake()
    {
        base.Awake();
        isStatic = true;
        _mr = GetComponent<MeshRenderer>();
        origMat = _mr.material;
        if (changeMat == null) changeMat = origMat;
    }

    public override void Interaction()
    {
        Debug.Log("Turn on");
        if (!active)
        {
            _mr.material = changeMat;
            active = true;
        } else
        {
            _mr.material = origMat;
            active = false;
        }
    }
}
