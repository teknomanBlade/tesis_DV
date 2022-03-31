using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public abstract class Object : MonoBehaviour
{
    protected Rigidbody _rb;

    public bool isHeld = false;
    public bool isStatic = false;
    public int weigthClass;

    protected virtual void Awake()
    {
        //gameObject.layer = GameVars.Values.GetObjectLayer();
        _rb = GetComponent<Rigidbody>();
    }

    public virtual bool Grab(int strength)
    {
        if (isStatic) return false;

        if (strength >= weigthClass)
        {
            _rb.isKinematic = true;
            isHeld = true;
            return true;
        }
        return false;
    }

    public virtual void Drop(Vector3 momentum = default(Vector3))
    {
        _rb.isKinematic = false;
        isHeld = false;
        _rb.velocity += momentum;
    }

    public virtual void Push(float strength, float force, Vector3 direction, Vector3 momentum = default(Vector3))
    {
        if (isStatic) return;

        if (isHeld)
        {
            Drop(momentum);
            if (strength > weigthClass)
            {
                _rb.AddForce(direction * force, ForceMode.Impulse);
            }
        } else
        {
            _rb.AddForce(direction * force, ForceMode.Impulse);
        }
        
    }

    public virtual void Interaction() { }

    public virtual void SetPos(Vector3 pos, Vector3 forward)
    {
        transform.position = pos;
        transform.forward = forward;
    }
}
