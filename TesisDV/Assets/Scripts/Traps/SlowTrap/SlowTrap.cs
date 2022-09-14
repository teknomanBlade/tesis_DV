using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowTrap : MonoBehaviour
{
    [SerializeField] private float _slowAmount;
    [SerializeField] private float _destroyTime;
    Animator _animator;

    void Start()
    {
        _animator = GetComponent<Animator>();
    }

    void Update()
    {
        _destroyTime -= Time.deltaTime;

        if (_destroyTime <=0)
        {
            _animator.SetTrigger("IsDestroyed");
        }
    }

    public void DestroyTrap()
    {
        Destroy(gameObject);
    }

    void OnTriggerEnter(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(_slowAmount);
        }
    }

    void OnTriggerExit(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(-_slowAmount);
        }
    }
}
