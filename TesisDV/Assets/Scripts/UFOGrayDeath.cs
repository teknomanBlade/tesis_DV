using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UFOGrayDeath : MonoBehaviour
{
    
    //public Gray Gray { get; set; }
    public LevelManager Level;
    private Transform _UFOSpinner;
    private float _arriveRadius;
    private float _tick;
    private float _lifeSpan;
    private float _maxSpeed;
    private float _maxForce;
    Vector3 _velocity;
    [SerializeField]
    private Animator _anim;
    // Start is called before the first frame update
    void Awake()
    {
        _arriveRadius = 2f;
        _maxSpeed = 10f;
        _maxForce = 8f;
        _UFOSpinner = transform.Find("UFOSpinner");
        _anim = transform.GetComponentInChildren<Animator>();
        _lifeSpan = 8f;
    }

    // Update is called once per frame
    void Update()
    {
        RotateUFOSpinner();
        OnStage();
        /*if(_gray)
            Arrive();
        
        if (_velocity != Vector3.zero)
        {
            transform.position += _velocity * Time.deltaTime;
            transform.forward = _velocity;
        }*/
    }
    private void OnStage()
    {
        _tick += Time.deltaTime;
        if (_tick >= _lifeSpan)
        {
            _tick = 0f;
            Level.UFOsPool.ReturnObject(this);
        }
    }
    public void PlayAnimBeamDeployed()
    {
        _anim.SetBool("IsBeamDeployed", true);
    }


    public void RotateUFOSpinner()
    {
        _UFOSpinner.Rotate(new Vector3(0f, 180f * Time.deltaTime, 0f));
    }

    public UFOGrayDeath InitializePosition(Vector3 spawnerPos)
    {
        transform.localPosition = spawnerPos;
        return this;
    }

    public UFOGrayDeath SetOwner(LevelManager level)
    {
        Level = level;
        return this;
    }

    /*public UFOGrayDeath SetTarget(Gray grayDead)
    {
        Gray = grayDead;
        return this;
    }

    void Arrive()
    {
        Vector3 desired = (Gray.transform.position - transform.position).normalized;
        float dist = Vector3.Distance(transform.position, Gray.transform.position);
        float speed = _maxSpeed;
        if (dist <= _arriveRadius)
        {
            speed = _maxSpeed * (dist / _arriveRadius);
        }
        desired *= speed;

        Vector3 steering = Vector3.ClampMagnitude(desired - _velocity, _maxForce);

        ApplyForce(steering);
    }

    void ApplyForce(Vector3 force)
    {
        _velocity += force;
    }*/
}
