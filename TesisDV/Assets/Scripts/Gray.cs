using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gray : MonoBehaviour
{
    [SerializeField]
    private GameObject _player;
    private Animator _anim;
    private Rigidbody _rb;
    public float distanceToPlayer;
    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public bool pursue = false;
    public bool stun = false;
    public bool skillEMP = false;

    private void Awake()
    {
        _anim = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        if (skillEMP)
        {
            _anim.SetFloat("Anim", 1f);
        }
        else
        {
            if (!stun)
            {
                distanceToPlayer = Vector3.Distance(_player.transform.position, transform.position);
                if (IsInSight())
                {
                    pursue = true;
                    _anim.SetFloat("Anim", 0.25f);
                }
                else
                {
                    pursue = false;
                    _anim.SetFloat("Anim", 0f);
                }

                if (pursue)
                {
                    Move();
                }
            }
            else
            {
                pursue = false;
            }
        }
    }

    public void Move()
    {
        var dir = _player.transform.position - transform.position;
        dir.y = 0f;
        transform.forward = dir;
        _rb.AddForce(transform.forward * 50f, ForceMode.Impulse);
    }

    private bool IsInSight()
    {
        if (pursue)
        {
            if (Vector3.Distance(_player.transform.position, transform.position) > disengageThreshold) return false;
        } else
        {
            if (Vector3.Distance(_player.transform.position, transform.position) > pursueThreshold) return false;
        }
        return true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, pursueThreshold);
        Gizmos.DrawWireSphere(transform.position, disengageThreshold);
    }

    public void Stun()
    {
        stun = true;
        _anim.SetFloat("Anim", 0.75f);
        Invoke("UnStun", 5f);
    }

    public void UnStun()
    {
        stun = false;
    }
}
