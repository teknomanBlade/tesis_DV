using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElectricTrap : Trap, IInteractable
{
    [SerializeField] private float _damagePerSecond;
    [SerializeField] private float _trapDuration;

    private void Start()
    {
        active = true; // Ahora las trampas empiezan encendidas.        
    }

    private void Update()
    {
        _trapDuration -= Time.deltaTime;

        if (_trapDuration <=0)
        {
            active = false;
        }
    }

    public void Interact()
    {
        if (!active)
        {
            active = true;
        }
        if(_trapDuration <= 0)
        {
            _trapDuration =10f;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        var enemyGray = other.GetComponent<Enemy>();

        if(enemyGray && !other.GetComponent<GrayModel>() && active)
        {
            other.GetComponent<Enemy>().TakeDamage(_damagePerSecond);
        }
    }
}
